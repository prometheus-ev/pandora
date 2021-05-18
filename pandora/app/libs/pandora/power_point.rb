require 'powerpoint'

class Pandora::PowerPoint
  def self.from_collection(collection)
    presentation = nil
    Dir.mktmpdir do |dir|
      data = []

      sis = collection.images.
        map{|i| Pandora::SuperImage.new(i.pid, image: i)}.
        sort_by{|i| i.meta['title'] || ''}

      sis.each do |si|
        d = begin
          filename = File.join(dir, "#{si.pid}.jpg")
          image_data = si.image_data('r600x600')

          if image_data
            File.open filename, 'w' do |f|
              f.write image_data
            end
          else
            system "ln -sfn #{Rails.root.join('..', 'rack-images', 'public', 'no_image_available.png')} #{filename}"
          end

          meta = []

          if v = si.meta['artist']
            meta << 'Artist'.t + ': ' + v
          end

          if v = si.meta['date']
            meta << 'Date'.t + ': ' + v
          end

          if v = si.meta['location']
            meta << 'Location'.t + ': ' + v
          end

          if v = si.meta['credits']
            meta << 'Credits'.t + ': ' + v
          end

          {title: si.meta['title'], path: filename, meta: meta}
        rescue ActiveResource::ServerError => e
          # data can't be found via elasticsearch
          nil
        end

        data << d if d
      end

      presentation = new(data)
      presentation.data # generates the presentation
    end

    presentation
  end

  def initialize(slides = [])
    @slides = slides
    @doc = build
  end

  def build
    Powerpoint::Presentation.new.tap do |doc|
      @slides.each do |slide|
        doc.add_picture_description_slide(
          slide[:title] || 'Title'.t,
          slide[:path],
          slide[:meta] || []
        )
      end
    end
  end

  def save(filename)
    File.open filename, 'w' do |f|
      f.write data
    end
  end

  def data
    unless @data
      Dir.mktmpdir do |d|
        outfile = "#{d}/presentation.pptx"
        @doc.save outfile
        @data = File.read outfile
      end
    end

    @data
  end
end
