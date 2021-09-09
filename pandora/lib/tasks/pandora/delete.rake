namespace :pandora do
  desc 'delete upsteam images'
  task delete_upstream_images: :environment do
    Source.all.each do |source|
      Pandora::ImagesDir.new.delete_upstream_images(source.name)
    end
  end

  desc 'delete obsolete upload images'
  task delete_obsolete_upload_images: :environment do
    Dir["#{ENV['PM_IMAGES_DIR']}/upload/original/*"].each do |upload_file|
      filename = File.basename(upload_file, File.extname(upload_file))
      upload = Upload.find_by_image_id(filename)
      
      if !upload
        puts "rm #{upload_file}"
        puts '-' * 100
        #system "rm #{upload_file}"
      end
    end
  end
end
