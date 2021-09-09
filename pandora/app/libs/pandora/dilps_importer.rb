class Pandora::DilpsImporter

  def initialize(name)
    if !Indexing::Index.client(false).indices.exists_alias(name: name)
      @source = Source.find_and_update_or_create_by(name: name, type: 'dump')
      @source.name.camelize.constantize.index
    end

    @source = Source.find_and_update_or_create_by(name: name, type: 'upload')
  end

  def import
    elastic = Pandora::Elastic.new

    records = elastic.scan(@source.name, 10)
    scroll_id = records['_scroll_id']
    record_count = 0

    while record_count < records['hits']['total']['value']
      records['hits']['hits'].each do |record|
        create_institutional_upload(record['_source'])
        record_count += 1
        printf "\rInstitutional uploads created: #{record_count} (#{record['_source']['record_id']})" unless Rails.env.test?
      end

      records = elastic.continue(scroll_id)
      scroll_id = records['_scroll_id']
    end
  end

  private

  def create_institutional_upload(index_record)
    if upload = Upload.find_by_index_record_id(index_record['record_id'])
      upload.destroy
    end

    upload = Upload.new

    index_record.sort.each do |key, value|
      next if ['record_id', 'record_id_original', 'path', 'artist_normalized', 'rating_count', 'rating_average', 'comment_count', 'user_comments'].include?(key)

      if upload.respond_to?(key)
        upload.send("#{key}=", value.join(', '))
      else
        raise Pandora::Exception, "the key index field #{key} is not available as upload field. Please update the upload model."
      end
    end

    # Fill required fields.
    if upload.title.blank?
      upload.title = "[Titel nicht vorhanden]"
    end

    if upload.rights_work.blank?
      upload.rights_work = "Nicht bekannt"
    end

    if upload.rights_reproduction.blank?
      if upload.credits.blank?
        upload.rights_reproduction = "Nicht bekannt"
        upload.credits = "[Bildnachweis nicht vorhanden]"
      end
    end

    # Set the existing index record ID in order to retain it
    # when indexing the uploads as institutional uploads.
    # See #1012.
    upload['index_record_id'] = index_record['record_id']

    upload.database = @source
    upload.approved_record = true

    image = Image.find_or_create_by(pid: index_record['record_id']) do |image|
      image.source = @source
    end
    si = Pandora::SuperImage.from(image)

    upload.filename_extension = si.extension

    Tempfile.create(binmode: true) do |f|
      f.write image.data(:original)
      f.flush

      file = Rack::Test::UploadedFile.new(f, si.mime_type.to_s, true)

      upload.file = file

      if !upload.save
        Rails.logger.info ''
        Rails.logger.info 'Could not save institutional upload.'
        Rails.logger.info "Index record ID: #{index_record['record_id']}"
        Rails.logger.info "Upload image ID: #{upload.image_id}"
        Rails.logger.info upload.errors.full_messages.join("\n")
      end
    end
  end
end
