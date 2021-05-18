require "json"

namespace :digirom do

  desc 'Import upload data from json'
  task import_upload_data_json: :environment do
    task_options = options_from_env
    data_dump = options_from_env[:data_dump]
    original_image_folder = options_from_env[:original_image_folder]
    owner_id = task_options[:owner_id]
    mapping_file_path = task_options[:mapping_file_path]

    upload_user = Account.find(owner_id)
    upload_user_database_id = upload_user.database ? upload_user.database.id : Source.create_user_database(upload_user)

    file = File.open data_dump
    data = JSON.load file
    file.close

    File.open(mapping_file_path, "w") do |mapping_file| # YAML

      data.each do |datum|
        upload = Upload.new
        upload.owner_id = owner_id
        upload.title = datum["title"]
        upload.credits = datum["credits"]
        upload.rights_reproduction = datum["rights_reproduction"]
        upload.rights_work = datum["rights_work"]
        upload.license = datum["license"]

        upload.resource_title = datum["resource_title"]
        upload.description = datum["description"]
        upload.artist = datum["artist"]
        upload.date = datum["date"]
        upload.institution = datum["institution"]

        upload.indexed_record = datum["indexed_record"]
        upload.index_record = datum["index_record"]
        upload.destroy_record = datum["destroy_record"]

        upload.inventory_no = datum["inventory_no"]
        upload.size = datum["size"]
        upload.photographer = datum["photographer"]
        upload.discoveryplace = datum["discoveryplace"]
        upload.other_persons = datum["other_persons"]
        upload.origin = datum["origin"]
        upload.genre = datum["genre"]
        upload.annotation = datum["annotation"]
        upload.text = datum["text"]
        upload.material = datum["material"]
        upload.location = datum["location"]
        upload.subtitle = datum["subtitle"]
        upload.iconography = datum["iconography"]
        upload.addition = datum["addition"]

        upload.approved_record = datum["approved_record"]
        upload.public_record =  datum["public_record"]

        datum["keywords"].each do |keyword_hash|
          if !(keyword = Keyword.find_by(title: keyword_hash["title"]))
            keyword = Keyword.create(title: keyword_hash["title"])
          end
          upload.keywords.push keyword
        end

        upload.file = "dummy" # required field; used instead of ActionDispatch::Http::UploadedFile; not persisted

        if upload.valid?
          upload.filename_extension = datum["filename_extension"]
          if upload.save

            mapping_file.puts({"old_id" => datum["id"], "new_id" => upload.id, "old_pid" => datum["image_id"], "new_pid" => upload.pid, "inventory_no" => datum["inventory_no"]}.to_yaml)

            import_image_path = upload.path(Upload.pconfig[:tmp_upload_path]) # Why tmp?
            export_image_path = !datum["inventory_no"].blank? ? 
              original_image_folder + "/" + datum["inventory_no"] + "." + upload.filename_extension :
              original_image_folder + "/" + datum["image_id"] + "." + upload.filename_extension

            if File.file?(export_image_path)
              File.open(export_image_path, 'r') do |export_image|
                File.open(import_image_path, 'w') {|import_image| import_image.write(export_image.read) }
              end
              upload.file_size = File.size?(import_image_path)
            end

            image = Image.new
            image.pid = upload.pid
            image.source_id = upload_user_database_id
            if image.save
              upload.update_attribute(:image_id, upload.pid)
              upload.update_attribute(:latitude, image.latitude)
              upload.update_attribute(:longitude, image.longitude)
            else
              puts "Could not save image: #{image}"
              debugger
            end
          else
            puts "Could not save upload: #{upload}"
            debugger
          end
        else
          puts "Upload invalid: #{upload}"
          debugger
        end
      end
    end

    # set parents for uploads
    mapping = {}
    YAML.load_documents(File.open mapping_file_path).each do |document|
      mapping[document["old_id"]]= document["new_id"]
    end

    data.each do |datum|
      if !datum["parent_id"].nil?
        child = Upload.find(mapping[datum["id"]])
        if !child.update(parent: Upload.find(mapping[datum["parent_id"].to_i]))
          puts "Could not update upload: #{child}"
          debugger
        end
      end
    end
  end

  desc 'Check for a user\'s missing upload images'
  task missing_upload_images: :environment do
    task_options = options_from_env
    upload_path = options_from_env[:upload_path]
    owner_id = options_from_env[:owner_id]
    mapping_file_path = options_from_env[:mapping_file_path]

    uploads = Account.find(owner_id).database.uploads

    missing_images = []

    uploads.each do |upload|
      if !File.exist?(upload_path + upload.image_id + "." + upload.filename_extension)
        missing_images.push upload.image_id
      end
    end

    mapping = {}
    YAML.load_documents(File.open mapping_file_path).each do |document|
      mapping[document["new_pid"]]= document["old_id"]
    end

    puts "#{missing_images.size} images are missing!"
    puts
    puts "Legacy upload ids with missing images:"
    missing_images.each do |missing_image|
      puts mapping[missing_image]
    end
  end

end
