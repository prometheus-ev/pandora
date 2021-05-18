require 'digest/md5'
require 'exifr/jpeg'

class Image < ApplicationRecord
  include Util::Config
  include Util::Attribution::OwnerMethods

  self.primary_key = 'pid'

  belongs_to              :source
  belongs_to              :item, optional: true
  has_one                 :upload, autosave: false
  has_many                :locations, :dependent => :destroy
  has_many                :comments, :dependent => :destroy
  has_many :collections_images, class_name: 'CollectionImage'
  has_many :collections, through: :collections_images
  has_and_belongs_to_many :voters, :class_name => 'Account', :uniq => true

  validates_presence_of :pid
  validate :must_have_record, on: :create

  before_create :set_source
  after_save :update_source_rating

  STATIC_FIELDS = %w[
    id pid oid primary path source_name source_title vgbk
  ].freeze

  ALL_STATIC_FIELDS = %w[all].concat(STATIC_FIELDS).freeze

  PREFIX_FOR = Hash.new { |hash, key|
    raise ArgumentError, "illegal field type: #{key}"
  }.update(
    :search  => 's',
    :sort    => 't',
    :display => 'd'
  ).freeze

  PREFIX_RE = Regexp.union(*PREFIX_FOR.values)

  DELEGATE_TYPES = [:search, :sort].freeze

  # \s Any whitespace character
  # *  Zero or more of
  FIELD_SPLIT_RE = %r{\s*\|\s*}

  PID_SEPARATOR  = '-'.freeze

  # Boost factor per source (0 < boost <= 200)
  # SOURCE_BOOST = Hash.nest(0, 100).update(pconfig[:source_boost])

  # Boost factor, normalized for Ferret::Document.new (0 < boost <= 2)
  # BOOST_BY_SOURCE = Hash.nest { |source| SOURCE_BOOST[source] / 100.0 }

  # Secret string for Apache Secure Download
  # REWRITE: we pull this from .env now
  ASD_SECRET = ENV['PM_ASD_SECRET'].freeze

  # Dimensions for various image sizes (small, medium, large)
  DIMENSIONS_FOR = {
    small: [140, 140],
    medium: [400, 400],
    large: 8192
  }.freeze

  URI_UNSAFE_RE = Regexp.union(URI::UNSAFE, /[\[\]]/).freeze

  MIRO_PIDS    = Set.new(load_cache(:miro_pids, [])).freeze
  WARBURG_PIDS = Set.new(load_cache(:warburg_pids, [])).freeze

  VGBK_LIST = Set.new(load_cache(:vgbk_list, []), &:downcase).freeze

  BASE_URL = pconfig[:base_url][Rails.env.to_s].freeze

  # Enumeration characters
  ENUM_CHARS = Array.new(16**2) { |i| i.to_s(16).rjust(2, '0') }.freeze

  SIMILARITY_WIDTH  = 48
  SIMILARITY_HEIGHT = 48

  def path=(path)
    @path = path
  end

  class << self
    attr_accessor :check_duplicates, :include_index_terms
  end

  def self.search(field, value)
    return all if field.blank? || value.blank?

    case field
    when 'title' then all
    else
      raise Pandora::Exception, "unknown search field #{field}"
    end
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when 'insertion_order'
      # only worḱs on Collection images association
      merge(CollectionImage.insertion_order(direction))
    when 'source_title'
      includes(:source).
      references(:source).
      order('sources.title' => direction)
    when 'rating_average' then order(score: direction)
    when 'rating_count' then order(votes: direction)
    when 'comment_count'
      joins('LEFT JOIN comments cs ON cs.image_id = images.pid').
      group('images.pid').
      order("count(DISTINCT cs.id) #{direction}")
    else
      raise Pandora::Exception, "unknown sort criteria for Image: #{column}"
    end
  end

  def self.uploads
    includes(:upload).
      references(:upload).
      where('uploads.id IS NOT NULL')
  end

  def self.non_uploads
    includes(:upload).
      references(:upload).
      where('uploads.id IS NULL')
  end

  # TODO check if actually used
  def self.pid_for(*args)
    args << nil if args.size < 2
    args.join(PID_SEPARATOR)
  end

  def self.url_for(image, size = :small)
    si = Pandora::SuperImage.new(image.pid, image: image)
    si.image_url(size)
  end

  def self.dummy?(image)
    [:miro, :png] if MIRO_PIDS.include?(image.pid)
  end

  def self.rights_warburg?(image)
    WARBURG_PIDS.include?(image.pid)
  end

  def self.valid_field?(field_or_name)
    @valid_fields ||= all_fields.map{|f| [f, true]}.to_h

    k = field_or_name.to_sym
    @valid_fields[k.to_s] || @valid_fields[field_from(k)]
  end

  def self.static_field?(field)
    (@static_field ||= Hash.nest { |k|
      ALL_STATIC_FIELDS.include?(k.to_s)
    })[field.to_sym]
  end

  def self.field_name_for(field, type)
    ((@field_name_for ||= {})[field.to_sym] ||= {})[type.to_sym] ||=
      static_field?(field) ? field.to_sym : :"#{PREFIX_FOR[type]}_#{field}"
  end

  # field_from(field_name_for(field, type), type) == field.to_s
  def self.field_from(field_name, type = nil)
    h, k = (@field_from ||= {})[field_name.to_sym] ||= {}, type && type.to_sym

    h.has_key?(k) ? h[k] : h[k] = if static_field?(field_name = field_name.to_s)
      field_name unless k
    else
      field_name[/\A#{k ? PREFIX_FOR[k] : PREFIX_RE}_(\w+)\z/, 1]
    end
  end

  def self.all_fields
    @all_fields ||= search_fields | sort_fields | store_fields
  end

  def self.search_fields
    @search_fields ||= pconfig[:search_fields]
  end

  def self.sort_fields
    @sort_fields ||= pconfig[:sort_fields]
  end

  def self.display_fields
    @display_fields ||= (search_fields - %w[unspecified]) | pconfig[:display_fields]
  end

  def self.display_fields_app
    display_fields + %w[database]
  end

  def self.display_fields_translated
    hash = {}
    display_fields_app.map{ |key|
      hash[key] = I18n.t(key.humanize_all, globalize: true)
    }
    hash
  end

  def self.location_fields
    @location_fields ||= pconfig[:location_fields]
  end

  def self.store_fields
    @store_fields ||= (STATIC_FIELDS - %w[id]) | display_fields
  end

  def record
    if pid.match(/^upload\-/)
      self
    else
      elastic_record_image
    end
  end

  def self.elastic_record?(id)
    Indexing::Index.exists?(id.split("-").first)
  end

  def self.elastic_record(id)
    r = Pandora::Elastic.new.record(id)
    r['found'] ? r : ElasticRecordImage.dummy_record
  end

  def self.elastic_record_image(id)
    er = elastic_record(id)
    # REWRITE: using elastic results directly so the structure is different, see
    # above
    # elastic_record = er['search_result']['hits']['hits'][0]
    elastic_record = er
    elastic_record_source = Source.find_by_name(id.split("-")[0])
    ElasticRecordImage.new(id, elastic_record, nil, elastic_record_source)
  end

  def elastic_record_image
    @elastic_record_image ||= self.class.elastic_record_image(id)
  end

  def pid
    id
  end

  def to_s
    descriptive_title
  end

  def to_param
    pid
  end

  def updated_at
    source.updated_at
  end

  # REWRITE: we rename the method so that we have access to the original
  # implementation
  def legacy_to_xml(options = {})
    skip, link = {}, options.delete(:link)

    %w[source link status extra].map { |key|
      skip[key.to_sym] = options.delete("skip_#{key}".to_sym)
    }

    # REWRITE: 'keywords' represents an association and that tries to find the
    # other fields on the keyword model, e.g. descriptive_title, we use :include
    # instead
    # to_xml(options.reverse_merge(
    #   :only       => [:pid, :votes, :score],
    #   :methods    => [:descriptive_title, *display_fields],
    #   :skip_nil   => true,
    #   :skip_types => true
    # )) { |xml|
    to_xml(options.reverse_merge(
      only:       [:pid, :votes, :score],
      methods:    [:descriptive_title, *(display_fields - ['keywords'])],
      include:    ['keywords'],
      skip_nil:   true,
      skip_types: true
    )) { |xml|
      yield xml if block_given?

      unless skip[:extra]
        xml.source source.fulltitle unless skip[:source] || !source
        xml.link   link             unless skip[:link]   || !link

        xml.tag!('status-as-of', Time.now.utc.xmlschema) unless skip[:status]
      end
    }
  end

  # REWRITE: still needed for uploads; called in SuperImage.to_txt
  def to_txt(options = {})
    fields = [
      :pid, :votes, :score,
      :descriptive_title, *display_fields
    ]

    txt = []
    fields.each do |field|
      label = I18n.t(field.to_s.humanize_all, globalize: true)
      value = self.send(field)
      txt << "#{label}: #{value}" if value.present?
    end

    if s = self.source
      label = I18n.t('Source', globalize: true)
      txt << "#{label}: #{source.fulltitle}"
    end

    if link = options.delete(:link)
      label = I18n.t('Link', globalize: true)
      txt << "#{label}: #{link}"
    end

    txt << Time.now.utc

    txt.join("\n\n")
  end

  def display_fields
    @display_fields ||= self.class.display_fields
  end

  # called
  def display_fields_hash
    hash = {}
    # REWRITE: see below
    si = Pandora::SuperImage.new(pid, image: self, elastic_record_image: elastic_record_image)

    self.class.display_fields_app.map{ |key|
      if key == "rights_work"
        hash.merge!({ "rights_work" => rights_representative })
      elsif key == "database"
        if self.source
          hash.merge!({ "database" => self.source.fulltitle })
        else
          hash.merge!({ "database" => "" })
        end
      else
        # REWRITE: we change this to not fail with an exception when fields are
        # not available
        # hash.merge!({ key => send(key) })
        hash[key] = si.attrib(key)
      end
    }
    hash
  end

  def rights_representative
    # Rights work of an upload record is always a String, of an elastic record always an Array.
    # Work with an Array in the following.
    rights_representative = rights_work
    if rights_representative.blank?
      rights_representative = ['']
    elsif rights_representative.is_a?(String)
      rights_representative = [rights_representative]
    end

    rights_representative.map { |right_representative|
      if right_representative == 'rights_work_warburg'
        'The Warburg Institute, London'
      elsif right_representative == 'rights_work_vgbk'
        'VG Bild-Kunst'
      else
        if !right_representative.blank?
          if Upload.pconfig[:rights_work].include?(right_representative)
            right_representative.t
          else
            CGI::escapeHTML(right_representative)
          end
        else
          ''
        end
      end
    }.join(' | ').html_safe
  end

  def location_fields
    @location_fields ||= self.class.location_fields
  end

  def descriptive_title(length = 80)
    @descriptive_title ||= begin
      t = []
      if record.respond_to?(:artist)
        record.artist.kind_of?(Array) ? artist = record.artist.join : artist = record.artist
      end
      if record.respond_to?(:title)
        record.title.kind_of?(Array) ? title = record.title.join : title = record.title
      end
      if record.respond_to?(:location)
        record.location.kind_of?(Array) ? location = record.location.join : location = record.location
      end
      if record.respond_to?(:discoveryplace)
        record.discoveryplace.kind_of?(Array) ? discoveryplace = record.discoveryplace.join : discoveryplace = record.discoveryplace
      end

      [[artist, title], [location, discoveryplace]].each { |i|
        j = []
        i.each { |k| j << k if k && !(k = k.gsub(/\s+/, ' ').strip).empty? }
        t << (t.empty? ? j : j.parenthesize) unless (j = j.join(': ')).empty?
      }

      t.empty? ? path.gsub(/.*?\/|\.[^.]*\z/, '') : t.join(' ')
    end

    # REWRITE String#chars was used to wrap the string in an
    # ActiveSupport::Multibyte::Chars instance to handle unicode decently. That
    # should now be provided by ruby itself.
    # TODO: test this extensively
    # unless length && (chars = @descriptive_title.chars).length > length
    unless length && @descriptive_title.length > length
      @descriptive_title
    else
      words = @descriptive_title[0, length].split(/(\s+)/)

      title = words[0..-3].join.sub(/\W+\z/, '')
      title.empty? && words.find { |word| !word.blank? } || title
    end
  end

  def filename(ext = mime_type)
    "#{to_s}_#{pid[-8..-1]}".to_filename(ext)
  end

  def owner
    @owner ||= source.owner
  end

  def owner_id
    @owner_id ||= owner.id unless owner.nil?
  end

  def mime_type
    # REWRITE: this doesn't work anymore
    # t = MIME::Types.of(path).first
    ext = path.split('.').last.downcase
    t = Mime::Type.lookup_by_extension(ext)
    t && t.content_type || 'image/jpeg'
  end

  def data(size = :small)
    Pandora::SuperImage.from(self).image_data(size)
  end

  def generate_md5sum(size = :large)
    image_data = data(size)

    if image_data
      Digest::MD5.hexdigest(image_data)
    end
  end

  # called in pandora/lib/tasks/pandora/images.rake
  def file_changed?
    if md5sum
      generate_md5sum != md5sum
    else
      false
    end
  end

  def checked?
    checked_at
  end

  def checked!
    update_attribute(:checked_at, Time.now.utc)
  end

  def vote(_rating, _user = nil)
    if votes == 0 && md5sum.blank?
      self.md5sum = generate_md5sum
    end

    self.score += _rating
    self.votes += 1

    voters << _user if _user

    Indexing::Index.rate(pid, rating, votes) unless upload_record?

    votes
  end

  def rated?
    votes > 0
  end

  def self.conditions_for_rated
    { :conditions => 'images.votes > 0' }
  end

  def rating
    rated? ? (score.to_f / votes) : 0.0
  end

  def open_access?
    source && source.open_access?
  end

  def source_name
    source_id ? source.name : super
  end

  def set_source
    self.source = Source.find_by_name(source_name) unless source_id
  end
  private :set_source

  def exif_metadata
    @exit_metadata ||= begin
      si = Pandora::SuperImage.new(pid, image: self)
      si.exif
    end
  end

  def exif_metadata_value_for(tag_name = 'exif')
    exif_metadata ? exif_metadata.send(tag_name) : nil
  end

  def latitude
    lat, lat_ref = exif_metadata_value_for('gps_latitude'), exif_metadata_value_for('gps_latitude_ref')
    lat && lat_ref ? lat.inject{ |m,v| m * 60 + v}.to_f / 3600 * (lat_ref == 'S' ? -1 : 1) : nil
  end

  def longitude
    long, long_ref = exif_metadata_value_for('gps_longitude'), exif_metadata_value_for('gps_longitude_ref')
    long && long_ref ? long.inject{ |m,v| m * 60 + v}.to_f / 3600 * (long_ref == 'W' ? -1 : 1) : nil
  end

  # overwrites #print implemented by Image(Kernel) in order to access the display field print
  def print
    method_missing(:print)
  end

  def method_missing(m, *a, &b)
    return super unless self.class.valid_field?(m)

    if upload_record?
      respond_to?(m) ? upload_record.send(m) : ''
    else
      # REWRITE: doesn't work anymore, see above
      # field = self.class.field_name_for(m, :display)
      # fr.send(self.class.valid_field?(field) ? field : m, *a, &b)
      self.elastic_record_image.send(m)
    end
  end

  def respond_to?(m, i = false, r = true)
    super(m, i) || if r && self.class.valid_field?(m) && (ur = upload_record?)

      field = self.class.field_name_for(m, :display)
      field_valid = self.class.valid_field?(field)

      if ur
        field_valid ? upload_record.respond_to?(m) : false
      else
        fr.respond_to?(field_valid ? field : m, i, false)
      end
    end || false
  end

  # TODO: adapt this for institutional user databases as well
  def upload_record?
    (source.user_database? || source.institutional_user_database?) if source
  end

  def upload_record
    upload
  end

  def has_approved_upload_record?
    upload_record? && upload.approved_record
  end

  def has_unapproved_upload_record?
    upload_record? && !upload.approved_record
  end

  def has_record?
    upload_record? || self.class.elastic_record?(id)
  end


  protected

    def must_have_record
      # TODO: this is brittle because the image becomes invalid if its elastic
      # counterpart is removed
      unless has_record?
        # REWRITE: there is only Errors#add now
        # errors.add_to_base('An image must have a Elastic, Ferret, or upload record associated with it.')
        errors.add :base, 'An image must have a Elastic or upload record associated with it.'
      end
    end

    def update_source_rating
      source.update_rating if rated? && source
    end

    class ImageError < StandardError
      def to_s(msg = nil)
        "[ImageError] #{msg}"
      end
    end

    class DuplicatePIDError < ImageError
      attr_reader :pid

      def initialize(pid)
        @pid = pid
      end

      def to_s
        super("PID #{pid} has already been taken")
      end
    end
end
