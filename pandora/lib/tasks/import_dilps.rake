namespace :dilps do

  desc 'Import dilps database as institutional uploads database'
  task import_dilps_db: :environment do
    options = options_from_env
    xml_path = options_from_env[:xml_path]
    images_path = options_from_env[:images_path]
    image_tag = options_from_env[:image_tag]
    institutional_upload_database_name = options_from_env[:institutional_upload_database_name]

    error_messages = []
    if !xml_path || xml_path.empty?
      error_messages.push("XML_PATH: You must specify the path to the xml dump document")
    end
    if !images_path || images_path.empty?
      error_messages.push("IMAGES_PATH: You must specify the path to the image directory corresponding to the dump metadata")
    end
    if !image_tag || image_tag.empty?
      error_messages.push("IMAGE_TAG: You must specify the tag name of the dump's records' image subelement, e. g. 'ng_oldenburg_uni_afrika_img' for oldenburg_afrika")
    end
    if !institutional_upload_database_name || institutional_upload_database_name.empty?
      error_messages.push("INSTITUTIONAL_UPLOAD_DATABASE_NAME: You must specify the name of the institutional upload database in which you want to import the dump's records")
    end

    if !error_messages.empty?
      error_messages.each { |error_message| puts error_message }
      abort
    end

    institutional_upload_database = Source.find_by(name: institutional_upload_database_name)
    @oldenburg_afrika = OldenburgAfrika.new
    @dilps_source_field_keys = ['artist', 'title', 'location', 'date', 'credits', 'rights_work', 'rights_reproduction', 'addition', 'annotation', 'genre', 'institution', 'isbn', 'keyword', 'material', 'size', 'technique']

    doc = File.open(xml_path) { |f| Nokogiri::XML(f) }
    doc.xpath("/root/row").each do |record|
      create_upload institutional_upload_database, record, images_path, image_tag
    end
  end

  def create_upload(database, record, images_path, image_tag, options = {})
    filename = record.xpath("./#{image_tag}/img_baseid/text()").to_s + "-" + record.xpath("./#{image_tag}/imageid/text()").to_s
    @oldenburg_afrika.record = record

    begin
      @dilps_source_field_keys.each do |source_field_key|
        options.merge!(source_field_key => source_field_value(source_field_key))
      end

      options.merge!(
        database: database,
        file: Rack::Test::UploadedFile.new(
          "#{images_path}/#{filename}.jpg",
          'image/jpeg'
        )
      )
    rescue StandardError => e
      puts e # file does not exist
    end

    if !((keyword = record.xpath("./keyword/text()").to_s).empty?)
      options[:keywords] = keyword
    end

    begin
      Upload.create!(options)
    rescue StandardError => e
      puts e # validation failed
    end
  end

  def source_field_value(source_field_key)
    source_field_value = @oldenburg_afrika.send(source_field_key)

    if source_field_value.blank?
      '-'
    else
      source_field_value
    end
  end

  def artist_field(record)
    name1 = record.xpath("./name1/text()").to_s
    name2 = record.xpath("./name2/text()").to_s
    if !name1.empty?
      if !name2.empty?
        "#{name1} | #{name2}"
      else
        name1
      end
    elsif !name2.empty?
      name2
    else
      ""
    end
  end

  def rights_work_field(record)
    if !(copyright = record.xpath("./copyright/text()")).empty?
      record.xpath("./copyright/text()").to_s
    else 
      "???"
    end
  end

  def document_field(record)
    document_elements = []
    document_elements.push record.xpath("./literature/text()").to_s
    document_elements.push record.xpath("./page/text()").to_s
    document_elements.push record.xpath("./figure/text()").to_s
    document_elements.push record.xpath("./table/text()").to_s
    document_elements.push record.xpath("./isbn/text()").to_s
    document_elements.reject!(&:empty?)
    document_elements.join(", ")
  end

end
