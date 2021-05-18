class Upload < ApplicationRecord

  include Util::Config

  belongs_to :database, class_name: 'Source', foreign_key: 'database_id', optional: true
  belongs_to :image, dependent: :destroy, optional: true
  belongs_to :parent, class_name: 'Upload', optional: true

  has_many :children, :class_name => 'Upload', :foreign_key => 'parent_id'
  has_and_belongs_to_many :keywords, :uniq => true, :order => 'title'

  validates_presence_of :file, :on => :create
  validates_presence_of :title
  validate :is_rights_reproduction_or_credits_completed?
  validate :is_rights_work_completed?

  REQUIRED = %w[file title]
  FILE_FORMATS = ['jpg', 'png', 'gif']

  validate on: :create do |u|
    if file.present?
      unless FILE_FORMATS.include?(self.filename_extension)
        u.errors.add :file, (
          file.content_type.to_s + ': ' + 'This file format is not supported.'.t + ' ' +
          'Please select a file with one of the following file formats:'.t + ' ' +
          FILE_FORMATS.join(', ')
        )
      end
    end

    unless u.database
      u.errors.add :database, 'uploads cannot be created without specifying an database'
    end
  end

  before_validation :extract_file_info, on: :create
  after_create :persist_file
  after_create :ensure_image
  after_validation :prepare_unaproval_handling
  after_save :ensure_collection_membership


  #############################################################################
  # Class methods
  #############################################################################

  def self.allowed(user, rw = :read)
    if user.admin? || user.superadmin?
      all
    else
      if user.dbadmin?
        if rw == :read
          where(database: [user.database] + user.admin_sources).or(where(approved_record: true))
        else
          where(database: [user.database] + user.admin_sources)
        end
      else
        if rw == :read
          where(database: user.database).or(where(approved_record: true))
        else
          where(database: user.database)
        end
      end
    end
  end

  def self.approved
    where(approved_record: true)
  end

  def self.unapproved
    where('NOT approved_record')
  end

  def self.search_columns(user = nil)
    search_columns = ['artist', 'title', 'location', 'description', 'keywords', 'inventory_no']

    if user && (user.admin? || user.superadmin?)
      search_columns + ['database']
    else
      search_columns
    end
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when 'title', 'updated_at', 'created_at', 'artist', 'location'
      order(column => direction)
    else
      raise Pandora::Exception, "unknown sort criteria for Upload: #{column}"
    end
  end

  def self.search(column, value)
    return all if column.blank? or value.blank?

    case column
    when 'artist', 'title', 'location', 'description', 'inventory_no'
      where("LOWER(#{column}) LIKE LOWER(?) collate utf8_bin", "%#{value}%")
    when 'keywords'
      includes(:keywords).references(:keywords).where('keywords.title LIKE ?', "%#{value}%")
    when 'database'
      includes(:database).references(:database)
        .where('sources.title LIKE ?', "%#{value}%")
        .or(
          includes(:database).references(:database)
            .where('sources.owner_type': 'Account', 'sources.owner_id': Account.where('firstname LIKE :value OR lastname LIKE :value', value: "%#{value}%" )))
    else
      raise Pandora::Exception, "unknown search criteria for Upload: #{column}"
    end
  end

  #############################################################################
  # Instance methods
  #############################################################################

  def file=(value)
    case value
    when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
      @file = value
      @content_type = value.content_type
      self.filename_extension = Mime::Type.lookup(value.content_type).symbol
    else
    end
  end

  def file(flags = 'rb')
    @file || begin
      new_record? ? nil : File.open(path, flags)
    end
  end

  def available_parents(user, object)
    return self.class.none unless user

    not_ids = children.pluck(:id) + [self.id]
    if object.instance_of?(Upload) && object.institutional?
      self.class.where(database: object.database).where('id NOT IN (?)', not_ids)
    else
      self.class.where(database: user.database).where('id NOT IN (?)', not_ids)
    end
  end

  def path
    raise StandardError, "can't calculate path without a pid" if id.blank?

    filename = "#{pid}.#{filename_extension}"
    File.join base_path, filename
  end

  def pid
    Image.pid_for("upload", Digest::SHA1.hexdigest(Array(id).join('|')))
  end

  def oid
    parent if parent_id
  end

  def keyword_list
    keywords.map{|k| k.title}.join("\n")
  end

  def keyword_list=(value)
    unless value.nil?
      self.keywords = Keyword.from_keyword_list(value)
    end
  end

  def any_latitude(options = {})
    latitude || image.try(:latitude) || (
      options[:default] ?
      Location.pconfig[:geographic_coordinates_default][:latitude] :
      nil
    )
  end

  def any_longitude(options = {})
    longitude || image.try(:longitude) || (
      options[:default] ?
      Location.pconfig[:geographic_coordinates_default][:longitude] :
      nil
    )
  end

  # TODO: fix NoMethodError (undefined method `active?' for #<Institution:0x0000000004329098>)
  # -> it's actually never called
  # def active?
  #   database.owner.active?
  # end

  def institutional?
    database.owner_type == "Institution"
  end

  private

    def base_path
      Upload.pconfig[:tmp_upload_path]
    end

    def is_rights_reproduction_or_credits_completed?
      if rights_reproduction.blank? || rights_reproduction == 'Other photographer' || rights_reproduction == 'Unknown' and credits.blank?
        errors.add(:reproduction_rights_or_credits, 'must be provided'.t)
        false
      else
        true
      end
    end

    def is_rights_work_completed?
      if rights_work.blank? || rights_work == 'Other holder of rights'
        errors.add(:rights_work, 'can\'t be blank'.t)
        false
      else
        true
      end
    end

    def extract_file_info
      if @file
        self.filename_extension = Mime::Type.lookup(@file.content_type).symbol
        self.file_size = @file.size
      end
    end

    def persist_file
      if @file
        FileUtils.mkpath(base_path) unless File.exist?(base_path)
        File.open(path, "wb") {|f| f.write(@file.read) }
        @file = nil
      end
    end

    def ensure_image
      self.image = Image.new({
        pid: pid,
        source: database
      }, without_protection: true)

      if self.image.save
        self.update_columns image_id: pid, latitude: image.latitude, longitude: image.longitude
      else
        raise StandardError, "the associated image could not be created, upload #{self.id} is dangling!"
      end
    end

    # since ensure_collection_membership runs after_save, the change tracking
    # information is lost so we record the relevant change in this
    # after_validation callback
    def prepare_unaproval_handling
      if approved_record_changed?
        @approved_record_changed = true
      end
    end

    # remove upload from shared and public collections if not approved
    def ensure_collection_membership
      if @approved_record_changed && !approved_record
        image.collections.each do |collection|
          if collection.shared? || collection.public?
            collection.images.delete(image)
          end
        end
      end
    end

end
