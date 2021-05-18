class Pandora::ImagesDir

  def initialize
    yaml_file = "#{ENV['PM_ORIGINALS_YML_DIR']}/originals.yml"

    unless File.exists?(yaml_file)
      raise "#{yaml_file} doesn't exist"
    end

    @upstream_urls = YAML.load_file(yaml_file)
  end

  def run
    if File.directory?(ENV['PM_IMAGES_DIR'])
      raise "directory #{ENV['PM_IMAGES_DIR']} already exists"
    end

    unless File.directory?(ENV['PM_ORIGINALS_DIR'])
      raise "#{ENV['PM_ORIGINALS_DIR']} isn't a directory"
    end

    system "mkdir -p #{ENV['PM_IMAGES_DIR']}/upload/original"

    Dir["#{ENV['PM_ORIGINALS_DIR']}/*"].each do |source|
      name = File.basename(source)
      next if name == 'upload'
      us = @upstream_urls[name]
      system "mkdir #{ENV['PM_IMAGES_DIR']}/#{name}"

      unless us
        if File.exists?("#{source}/original")
          system "ln -sfn #{source}/original #{ENV['PM_IMAGES_DIR']}/#{name}/original"
        end
      end
    end
  end

  def delete_upstream_images(source_name)
    Rails.logger.info 'Deleting upstream images of source ' + source_name + '.'

    source_dir = "#{ENV['PM_IMAGES_DIR']}/" + source_name

    if @upstream_urls[source_name]
      system "rm -rf #{source_dir}/*"
    end
  end

end
