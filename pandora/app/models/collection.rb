class Collection < ApplicationRecord

  include Util::Config
  include Util::Attribution

  has_many                :forks,  :class_name => 'Collection', :foreign_key => 'parent_id'
  has_many                :comments, lambda{where('comments.image_id IS NULL')}, dependent: :destroy
  belongs_to              :parent, :class_name => 'Collection', :foreign_key => 'parent_id', optional: true
  belongs_to              :owner,  :class_name => 'Account',    :foreign_key => 'owner_id'
  belongs_to              :thumbnail, class_name: 'Image', optional: true
  has_many :collections_images, class_name: 'CollectionImage'
  has_many :images, through: :collections_images, after_remove: :content_changed, after_add: :content_changed
  has_and_belongs_to_many :keywords, :uniq => true, :order => 'title'
  has_and_belongs_to_many(:viewers,
    class_name: 'Account',
    join_table: 'collections_viewers',
    uniq: true,
    before_add: :viewer_added,
    after_add: :record_new_viewer,
    after_remove: :record_removed_viewer
  )
  has_and_belongs_to_many(:collaborators,
    class_name: 'Account',
    join_table: 'collections_collaborators',
    uniq: true,
    before_add: :collaborator_added,
    after_add: :record_new_collaborator,
    after_remove: :record_removed_collaborator
  )

  after_create :save_images


  REQUIRED = %w[title]
  validates_presence_of   *REQUIRED
  validates_uniqueness_of :title, scope: :owner_id

  validate(
    :validate_viewers_and_collaborators, 
    :validate_no_unapproved_uploads
  )

  def validate_viewers_and_collaborators
    if @viewer_list
      not_found = @viewer_list - viewers.map{|a| a.login}
      if not_found.size > 0
        errors.add :viewers, '-- some users were invalid or could not be found: %s' / not_found.join(', ')
      end
    end

    if @collaborator_list
      not_found = @collaborator_list - collaborators.map{|a| a.login}
      if not_found.size > 0
        errors.add :collaborators, '-- some users were invalid or could not be found: %s' / not_found.join(', ')
      end
    end
  end

  def validate_no_unapproved_uploads
    making_public = public_access_changed? && !public_access.blank?
    sharing = @viewer_added || @collaborator_added

    if making_public || sharing
      if has_unapproved_uploads?
        errors.add :base, "Collections containing unapproved uploads can't be made public and can't be shared".t
      end
    end
  end

  # an association callback to record when a viewer was added so that we can
  # pick up the information during validation
  def viewer_added(viewer)
    @viewer_added = true
  end

  # an association callback to record when a collaborator was added so that we can
  # pick up the information during validation
  def collaborator_added(collaborator)
    @collaborator_added = true
  end
  
  def new_viewers
    @new_viewers ||= []
  end
  
  def new_collaborators
    @new_collaborators ||= []
  end
  
  def removed_viewers
    @removed_viewers ||= []
  end
  
  def removed_collaborators
    @removed_collaborators ||= []
  end
  
  def record_new_viewer(sharee)
    new_viewers << sharee
  end
  
  def record_new_collaborator(sharee)
    new_collaborators << sharee
  end
  
  def record_removed_viewer(sharee)
    removed_viewers << sharee
  end
  
  def record_removed_collaborator(sharee)
    removed_collaborators << sharee
  end
  
  def notify_sharees
    new_collaborators.each do |collaborator|
      AccountMailer.collaborator_changed(collaborator, self, :added, :collaborator).deliver_now
    end
    
    removed_collaborators.each do |collaborator|
      AccountMailer.collaborator_changed(collaborator, self, :removed, :collaborator).deliver_now
    end
  end

  serialize :links, Array
  serialize :references, Array

  def self.owned_by(user)
    return none unless user

    if user.is_a?(String)
      includes(:owner).
      references(:owner).
      where('accounts.login LIKE ?', user)
    else
      where(owner_id: user.id)
    end
  end

  def self.allowed(user, rw = :read)
    return none unless user

    ids = if rw == :read
      query = sanitize_sql_array [
        '
            SELECT collections.id
            FROM collections
            WHERE owner_ID = :user_id
          UNION
            SELECT collections.id
            FROM collections
            WHERE public_access IN (:verbs)
          UNION
            SELECT collections.id
            FROM collections
              LEFT JOIN collections_viewers cv ON cv.collection_id = collections.id
            WHERE cv.account_id = :user_id
          UNION
            SELECT collections.id
            FROM collections
              LEFT JOIN collections_collaborators cc ON cc.collection_id = collections.id
            WHERE cc.account_id = :user_id
        ',
        {
          user_id: user.id,
          verbs: ['read', 'write']
        }
      ]

      connection.select_values(query)
    else
      query = sanitize_sql_array [
        '
            SELECT collections.id
            FROM collections
            WHERE owner_ID = :user_id
          UNION
            SELECT collections.id
            FROM collections
            WHERE public_access IN (:verbs)
          UNION
            SELECT collections.id
            FROM collections
              LEFT JOIN collections_collaborators cc ON cc.collection_id = collections.id
            WHERE cc.account_id = :user_id
        ',
        {
          user_id: user.id,
          verbs: ['write']
        }
      ]

      connection.select_values(query)
    end

    where(id: ids)
  end

  # return a scope representing all public collections
  # @param rw [:read, :write] the access level to check agains
  # @return [ActiveRecord::Relation] the scope representing the collections
  def self.public(rw = :read)
    rw == :read ?
      where(public_access: ['read', 'write']) :
      where(public_access: 'write')
  end

  # return a scope representing all shared collections accessible by a given
  # user
  # @param user [Account] the user
  # @param rw [:read, :write] the access level to check agains
  # @return [ActiveRecord::Relation] the scope representing the collections
  def self.shared(user, rw = :read)
    case rw
    when :read
      joins('LEFT JOIN collections_collaborators cc ON cc.collection_id = collections.id').
      joins('LEFT JOIN collections_viewers AS cv ON cv.collection_id = collections.id').
      where('cc.account_id = :id OR cv.account_id = :id', id: user.id)
    when :write
      joins('LEFT JOIN collections_collaborators cc ON cc.collection_id = collections.id').
      where('cc.account_id = :id', id: user.id)
    else
      raise Pandora::Exception, "unknown access mode: #{rw.inspect}"
    end
  end

  def self.not_shared(user)
    ids = self.public.pluck(:id) + self.sharing(user).pluck(:id)
    return all if ids.empty?

    where('id NOT IN (?)', ids)
  end

  def self.sharing(user)
    owned_by(user).
    joins('LEFT JOIN collections_collaborators cc ON cc.collection_id = collections.id').
    joins('LEFT JOIN collections_viewers AS cv ON cv.collection_id = collections.id').
    where('cc.account_id IS NOT NULL OR cv.account_id IS NOT NULL')
  end

  def self.search(field, value)
    return all if value.blank?

    case field
    when 'title' then where('title like ?', "%#{value}%")
    when 'description' then where('description like ?', "%#{value}%")
    when 'keywords'
      joins('LEFT JOIN collections_keywords ck ON ck.collection_id = collections.id').
      joins('LEFT JOIN keywords k ON ck.keyword_id = k.id').
      where('k.title like ?', "%#{value}%").
      distinct
    when 'owner'
      includes(:owner).
      references(:owner).
      where("
        accounts.login LIKE :v OR
        CONCAT(accounts.firstname, ' ', accounts.lastname) LIKE :v",
        v: "%#{value}%"
      )
    when 'image_pid'
      includes(:images).
      references(:images).
      where('images.pid in (?)', value)
    else
      raise Pandora::Exception, "unknown search field #{field}"
    end
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when 'title' then order('title' => direction)
    when 'updated_at' then order('updated_at' => direction)
    when 'owner'
      includes(:owner).
      references(:owner).
      order('accounts.lastname' => direction)
    else
      raise Pandora::Exception, "unknown sort criteria for Collection: #{column}"
    end
  end

  # count the number of collections an image is part of, the output is gruoped
  # by collection type and image pid
  # @param [Array<String>, String] pids the pid or list of pids to calculate
  #   counts for
  # @param [Account] account the account to base shared collection counts on
  # @return [Hash] a map with pids as keys and counts as values
  # @example
  #   Collection.counts_for('daumier-123...', current_user)
  #   #=> {
  #     'daumier-123...' => {
  #       'own' => 1, 'shared' => 2, 'public' => 6, 'meta_image' => 0
  #     }
  #   }
  def self.counts_for(pids, account)
    query = "
      SELECT
        frame.pid AS pid,
        COALESCE(SUM(frame.is_owned), 0) AS own,
        COALESCE(SUM(frame.is_shared), 0) AS shared,
        COALESCE(SUM(frame.is_public), 0) AS public
      FROM
        (
          SELECT
            ci.image_id AS pid,
            c.owner_id = :account_id AS is_owned,
            c.public_access = 'read' OR c.public_access = 'write' AS is_public,
            viewers.id = :account_id OR collaborators.id = :account_id AS is_shared
          FROM
            collections_images as ci
            INNER JOIN collections c ON c.id = ci.collection_id
            LEFT JOIN collections_viewers cv ON cv.collection_id = c.id
            LEFT JOIN accounts viewers ON viewers.id = cv.account_id
            LEFT JOIN collections_collaborators cc ON cc.collection_id = c.id
            LEFT JOIN accounts collaborators ON collaborators.id = cc.account_id
          WHERE
            ci.image_id IN (:pids)
        ) AS frame
      GROUP BY
        frame.pid
    "
    sql = sanitize_sql_array([
      query,
      account_id: account.id,
      pids: Array.wrap(pids)
    ])

    result = ApplicationRecord.connection.select_all(sql)

    counts = {}
    result.rows.each do |row|
      attribs = result.columns.zip(row).to_h
      pid = attribs.delete 'pid'
      counts[pid] = attribs
    end

    counts
  end

  # association callback to make sure that the thumbnail_id
  # is set when there are images available and it is empty. Also its removed
  # when thumbnail is removed from the collection
  # we also touch the object when its contents are changed
  def content_changed(image)
    if id = thumbnail_id
      if !images.find_by(pid: id)
        self.thumbnail_id = nil
        unless new_record?
          update_column :thumbnail_id, nil
        end
      end
    end

    if !thumbnail_id
      if image = images.first
        self.thumbnail_id = image.pid
        unless new_record?
          update_column :thumbnail_id, image.pid
        end
      end
    end

    touch unless new_record?
  end

  def has_unapproved_uploads?
    images.uploads.where('NOT uploads.approved_record').count > 0
  end

  def collaborator_list
    collaborators.map{|a| a.login}.join("\n")
  end

  def collaborator_list=(value)
    unless value.nil?
      logins = value.split(/\s*\r?\n+\s*/).reject{|i| i.blank?}
      @collaborator_list = logins
      self.collaborators = Account.where(login: logins).to_a
    end
  end

  def viewer_list
    viewers.map{|a| a.login}.join("\n")
  end

  def viewer_list=(value)
    unless value.nil?
      logins = value.split(/\s*\r?\n+\s*/).reject{|i| i.blank?}
      @viewer_list = logins
      self.viewers = Account.where(login: logins).to_a
    end
  end

  def keyword_list
    keywords.map{|k| k.title}.join("\n")
  end

  def keyword_list=(value)
    unless value.nil?
      self.keywords = Keyword.from_keyword_list(value)
    end
  end

  attr_accessor :image_list

  # callback to save the images from @image_list
  def save_images
    if @image_list.present?
      pids = @image_list.split(/\s*,\s*/).reject{|i| i.blank?}
      self.images = Image.where(pid: pids).to_a
    end
  end

  def shared_with?(account)
    viewers.include?(account) || collaborators.include?(account)
  end

  def publicly_readable?
    public_access == 'read'
  end

  def publicly_writable?
    public_access == 'write'
  end

  def public?
    publicly_readable? || publicly_writable?
  end

  def private?
    !publicly_readable? && !publicly_writable?
  end

  def shared?
    viewers.any? || collaborators.any?
  end

  def readable?(account)
    writable?(account) || viewers.include?(account) || publicly_readable?
  end

  def writable?(account)
    collaborators.include?(account) || publicly_writable?
  end

  def active?
    owner.active?
  end

  def image_count
    @image_count ||= images.count
  end

  def visible_images(user)
    visible_images = []
    if user
      visible_images = images.
        includes(:upload, source: :institution).
        references(:upload).
        joins("left outer join uploads on images.pid = uploads.image_id").
        joins("left outer join sources on uploads.database_id = sources.id").
        joins("left outer join admins_sources on sources.id = admins_sources.source_id").
        where("uploads.approved_record OR uploads.id IS NULL OR 
        ((sources.owner_type like 'Account' AND sources.owner_id = #{user.id}) OR 
        (sources.owner_type like 'Institution' AND admins_sources.account_id = #{user.id}))")
    end
    visible_images
  end

  def visible_thumbnail(user)
    if thumbnail && thumbnail.has_unapproved_upload_record? && 
      (!user || thumbnail.upload_record.institutional? ? 
      !thumbnail.upload_record.database.source_admins.include?(user) : thumbnail.upload_record.database.owner != user)
      nil
    else
      thumbnail
    end
  end

  def links=(value)
    self[:links] = from_textarea(value).map { |link|
      link.strip!
      link.gsub!('"', '%22')

      link =~ /\A[a-z]+:\/\//i ? link : "http://#{link}"
    }
  end

  def references=(value)
    self[:references] = from_textarea(value)
  end

  def to_s
    title
  end

  def to_xml(options = {})
    link              = options.delete(:link)
    skip_associations = options.delete(:skip_associations)

    options.reverse_merge!(
      :only       => [:id, :title, :description],
      :skip_nil   => true,
      :skip_types => true
    )

    super(options) { |xml|
      yield xml if block_given?

      unless skip_associations
        xml.keywords do
          keywords.each { |k| xml.keyword k.title }
        end
      end

      xml.link link if link

      opts = {}
      opts[:type] = 'datetime' unless options[:skip_types]
      xml.tag!('status-as-of', opts, Time.now.utc.xmlschema)
    }
  end

  # REWRITE: we override Resourceful#to_txt so that we don't need the ar
  # serializer
  def to_txt(options = {})
    fields = [
      :id, :title, :description
    ]

    txt = []
    fields.each do |field|
      label = I18n.t(field.to_s.humanize_all, globalize: true)
      value = self.send(field)
      txt << "#{label}: #{value}" if value.present?
    end

    if link = options.delete(:link)
      label = I18n.t('Link', globalize: true)
      txt << "#{label}: #{link}"
    end

    txt << Time.now.utc

    txt.join("\n\n")
  end

end
