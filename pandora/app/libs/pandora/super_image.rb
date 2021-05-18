require 'rack_images'

class Pandora::SuperImage
  def initialize(pid, options = {})
    @pid = pid
    @image = options[:image]
    @upload = options[:upload]
    @elastic_record = options[:elastic_record]
    @elastic_record_image = options[:elastic_record_image]
    @search_result = options[:search_result]
    @collection_counts_cache = options[:collection_counts]
    preload!
  end

  def self.from(object, options = {})
    case object
    when String then new(object, options)
    when Image then new(object.pid, options.merge(image: object))
    when ElasticRecordImage
      new(object.pid, options.merge(elastic_record_image: object))
    when Upload then new(object.pid, upload: object)
    when Pandora::SuperImage then object
    when Array
      object.map do |image|
        er = options[:elastic_records].find{|r| r['found'] && r['_id'] == image.pid}
        new(image.pid, options.merge(
          image: image,
          elastic_record: er
        ))
      end
    else
      raise Pandora::Exception, "unknown image object: #{object.inspect}"
    end
  end

  # tries to pull relevant objects from the objects already available
  def preload!
    if @image
      if eri = @image.instance_variable_get('@elastic_record_image')
        @elastic_record_image ||= eri
      end

      if @image.association(:upload).loaded?
        @upload ||= @image.upload
      end

      if @image.association(:source).loaded?
        @source ||= @image.source
      end
    end

    if @upload
      if @upload.association(:image).loaded?
        @image ||= @upload.image
      end
    end

    if @elastic_record
      @elastic_record_image ||= ElasticRecordImage.new(@pid, @elastic_record, self, source)
    end

    if @elastic_record_image
      @source ||= @elastic_record_image.source
    end

    if @elastic_record_image
      @elastic_record ||= @elastic_record_image.elastic_record
    end
  end

  attr_reader :pid

  def self.find(pid)
    si = new(pid)

    if si.upload?
      return si if si.upload ? si : ()
    else # elastic record
      elastic_found = si.elastic_record["_source"]["path"] != "not-available"
      image_found = Image.find_by(pid: pid)

      return si if elastic_found || image_found
    end

    raise ActiveRecord::RecordNotFound
  end

  def elastic?
    !upload?
  end

  def upload?
    source_id == 'upload'
  end

  def no_longer_available?
    elastic? && elastic_record['found'] == false
  end

  def upload
    @upload ||= Upload.find_by(image_id: @pid)
  end

  def image
    @image ||= begin
      return upload.image if upload?

      image = nil

      Image.with_lock 'si' do
        image = Image.find_by(pid: pid)

        if image
          image.source ||= Source.find_by!(name: source_id)
          image.save! if image.source_id_changed?
        else
          image = Image.create!(
            pid: pid,
            source: Source.find_by!(name: source_id)
          )
        end
      end

      image
    end
  end

  def elastic_record
    @elastic_record ||= begin
      Pandora::Elastic.new.record(@pid)
    end
  end

  def record
    upload? ? image : elastic_record_image
  end

  def has_record?
    upload? ? image.has_record? : elastic_record_image.has_record?
  end

  def source_id
    @source_id ||= pid.split('-').first
  end

  def source
    @source ||= begin
      # we need to ensure that the source is actually present because the image
      # might have been passed in to the constructor
      image.source ||= Source.find_by!(name: source_id)
      image.save! if image.source_id_changed?

      image.source
    end
  end

  def source_title
    source.title
  end

  def elastic_record_image
    @elastic_record_image ||= ElasticRecordImage.new(pid, elastic_record, self, source)
  end

  def attrib(name)
    return image.send(name) if image.respond_to?(name)

    if upload?
      return upload.send(name) if upload.respond_to?(name)
    else
      eri = elastic_record_image
      value = eri.send(name) if eri && eri.respond_to?(name)
      value = eri.attrib(name) if value.blank?
      return (value.is_a?(Array) ? value.join(', ') : value)
    end

    nil
  end

  def path
    elastic? ? elastic_record_image.path : "#{image.upload.pid}.#{image.upload.filename_extension}"
  end

  def to_s
    image.to_s
  end

  def to_txt(options = {})
    elastic? ? elastic_record_image.to_txt(options) : image.to_txt(options)
  end

  def filename(ext = nil)
    ext ||= extension
    "#{to_s}_#{pid[-8..-1]}".to_filename(ext)
  end

  def extension
    if m = path.match(/[^\/]+\.([a-zA-Z0-9]+)$/)
      m[1].downcase
    end
  end

  def mime_type
    if extension
      # if the extension can be read from the path (see above), we assume its
      # correct
      Mime::Type.lookup_by_extension(extension)
    else
      # otherwise, we have to fetch the image data to make sure
      mime_type = nil
      Dir.mktmpdir 'pandora-mime-type-verify-' do |dir|
        filename = "#{dir}/image.dat"
        File.open filename, 'wb' do |f|
          f.write image_data('original')
        end
        mime_type = Mime::Type.lookup(`file -b -i #{filename}`)
      end
      mime_type
    end
  end

  def meta
    @meta ||= {
      'title' => title,
      'artist' => artist,
      'date' => date,
      'location' => location,
      'credits' => (credits || []).join(' | ')
    }
  end

  def display_fields
    upload? ? image.display_fields : elastic_record_image.display_fields
  end

  def relevance
    upload? ? nil : value_list(elastic_record['_score'])
  end

  def title
    upload? ? image.title : value_list(elastic_record_image.title)
  end

  def artist
    upload? ? image.artist : value_list(elastic_record_image.artist)
  end

  def date
    upload? ? image.date : value_list(elastic_record_image.date)
  end

  def location
    if upload?
      if image.location.blank? && !upload.latitude.blank? && !upload.longitude.blank?
        "#{upload.latitude}, #{upload.longitude}"
      else
        image.location
      end
    else
      value_list(elastic_record_image.location)
    end
  end

  def location_fields
    upload ? image.location_fields : nil
  end

  def credits
    if upload?
      image.credits.present? ? [image.credits] : []
    else
      elastic_record_image.credits
    end
  end

  def rating
    image.rating
  end

  def votes
    image.votes
  end

  def voted_by?(account)
    image.voters.include?(account)
  end

  def rating_average
    upload? ? image.rating : elastic_record_image.rating.to_f
  end

  def rating_count
    upload? ? image.votes : elastic_record_image.votes.to_i
  end

  # @see ::Collection#counts_for
  def collection_counts(account)
    if @collection_counts_cache
      @collection_counts_cache[pid]
    else
      Collection.counts_for(pid, account)[pid]
    end
  end

  def collection_counts_any?(account)
    results = @collection_counts_cache || Collection.counts_for(pid, account)
    return false if results[pid].blank?
    results[pid].any? do |key, count|
      count > 0
    end
  end

  def rights_work
    if upload?
      # upload records have 'VG Bild-Kunst' in the rights_work column
      return ['rights_work_vgbk'] if upload.rights_work == 'VG Bild-Kunst'

      [upload.rights_work]
    else
      value_list(elastic_record['_source']['rights_work'])
    end
  end

  def rights_reproduction
    upload? ? upload.rights_reproduction : elastic_record['_source']['rights_reproduction']
  end

  def record_object_id
    upload? ? nil : value_list(elastic_record['_source']['record_object_id'])
  end

  def updated_at
    upload.updated_at if upload?
  end

  def created_at
    upload.created_at if upload?
  end

  def comment_count
    image.comments.size
  end

  def comments
    image.comments.map{|c| c.text}.join(' | ')
  end

  # used to retrieve the insertion date into a particular collection
  def inserted_at(collection)
    # TODO
    nil
  end

  # parents, siblings and children of uploads, [] for non-uploads
  # @param [Account] account the account to check authorization against
  # @return [Array<Pandora::SuperImage>] the parents and children of the upload
  def associated(account)
    return [] unless upload?

    results = []

    results += upload.children.includes(:image).map do |upload|
      self.class.new(upload.image_id, upload: upload, image: upload.image)
    end

    if upload.parent.present?
      results << self.class.from(upload.parent)
      results += upload.parent.children.where.not(id: upload.id).includes(:image).map do |upload|
        self.class.new(upload.image_id, upload: upload, image: upload.image)
      end
    end

    results.uniq.select do |result|
      account.allowed?(result.image, :read)
    end
  end

  def parent
    return nil unless upload?

    upload.parent
  end

  # similar images (according to elasticsearch's "more like this" functionality)
  # @param [Integer] count the amount of images to fetch
  # @return [Array<Pandora::SuperImage>] the related images
  def related(count = 4)
    return [] if upload?

    response = Pandora::Elastic.new.more_like_this(pid)
    results = response['hits']['hits'].map do |hit|
      self.class.new(hit['_id'], elastic_record: hit)
    end

    # TODO: we should do this by aksing elasticearch for only that amount of
    # images
    results[0..(count - 1)]
  end

  # images showing the same object according to field 'elastic_record_id' in
  # elasticsearch
  # @return [Array<Pandora::SuperImage>] the image aspects
  def aspects
    return [] if upload?

    if @search_result
      # if a search result is available, it includes the aspect data
      @search_result.aspects_for(pid).map do |hit|
        self.class.new(hit['_id'], elastic_record: hit)
      end
    else
      pobject_id = elastic_record_image.pobject_id || []
      response = Pandora::Elastic.new.by_object_ids(pobject_id)
      response['hits']['hits'].map do |hit|
        self.class.new(hit['_id'], elastic_record: hit)
      end
    end
  end

  def display_field(display_field)
    if upload?
      [image.send(display_field)] if (image.respond_to?(display_field) && !image.send(display_field).blank?)
    else
      elastic_record_image.display_field(display_field)
    end
  end

  def value_list(array)
    case array
    when Array
      array.empty? ? nil : array.join(' | ')
    when String
      array
    else
      nil
    end
  end

  def image_path(resolution = :small)
    resolution = resolution_for(resolution)

    if path == 'miro'
      file = (I18n.locale == :en ? 'miro.png' : "miro.#{I18n.locale}.png")
      "/dummy/#{resolution}/#{file}"
    else
      # remove the initial slash
      path.gsub! /^\//, ''

      # base64-encode the string to avoid decoding issues during transfer
      base64 = RackImages::Resizer.encode64(path)

      "/#{source_id}/#{resolution}/#{base64}"
    end
  end

  def image_data(resolution = :small, options = {})
    if ENV['PM_USE_TEST_IMAGE'] == 'true'
      return File.read("#{Rails.root}/public/images/test.png")
    end

    options.reverse_merge! dummy: false

    path_info = image_path(resolution)
    file = RackImages::Resizer.new.run(path_info)
    file.read
  rescue RackImages::Exception => e
    if options[:dummy]
      file = "#{ENV['PM_ROOT']}/rack-images/public/no_image_available.png"
      File.read(file)
    else
      nil
    end
  end

  def image_url(resolution = :small)
    if ENV['PM_USE_TEST_IMAGE'] == 'true'
      return "#{ENV['PM_BASE_URL']}/images/test.png"
    end

    path_info = image_path(resolution)

    token = ::RackImages::Secret.token_for(path_info)

    connector = (path_info.match(/\?/) ? '&' : '?')
    "#{ENV['PM_RACK_IMAGES_BASE_URL']}#{path_info}#{connector}_asd=#{token}"
  end

  # def base_url
  #   @base_url ||= Image.pconfig[:base_url][Rails.env.to_s]
  # end

  def resolution_for(label_or_number)
    case label_or_number
    when String then label_or_number
    when :original then 'original'
    when :small then 'r140'
    when :medium then 'r400'
    when :large then 'r8192'
    when Integer then "r#{label_or_number}"
    else
      raise "unknown resolution specifier: #{label_or_number}"
    end
  end

  def exif(options = {})
    data = image_data(:original)
    return nil unless data

    @exif ||= EXIFR::JPEG.new(StringIO.new(data))
  rescue EXIFR::MalformedJPEG => e
    nil
  end


  # comparisons

  def eql?(other)
    pid.eql?(other.pid)
  end

  def hash
    pid.hash
  end
end
