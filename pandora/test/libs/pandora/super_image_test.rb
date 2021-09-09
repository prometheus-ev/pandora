require 'test_helper'

class SuperImageTest < ActiveSupport::TestCase
  test 'it should work for an upload' do
    with_real_images do
      si = Pandora::SuperImage.new(Upload.first.pid)
      assert_equal 'Jean-Baptiste Dupont: A upload (Köln)', si.to_s
      assert_equal 'image/jpeg', si.mime_type.to_s
      assert_equal 'jpg', si.extension
      assert_match /^upload-[a-f0-9]+\.jpg$/, si.path
      assert_match /^Jean_Baptiste_Dupont_A_upload_Koeln_[a-f0-9]+\.jpg/, si.filename
      assert_equal 'upload', si.source_id
      assert_equal 'upload', si.source.type
      assert_match /^http:\/\/localhost:47001\/rack-images\/upload\/r140\/[a-zA-Z0-9\+\/]+\?_asd=[a-f0-9]+$/, si.image_url
    end
  end

  if production_sources_available?
    test 'it should work for a elastic image' do
      with_real_images do
        pid = 'daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6'
        si = Pandora::SuperImage.new('daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')

        assert_equal 'Honoré Victorin Daumier: Don Qichotte lisant --- Don Quichotte --- Don', si.to_s
        assert_equal 'image/jpeg', si.mime_type.to_s
        assert_equal 'jpg', si.extension
        assert_match /img\/DR7194_557(_a)?\.jpg/, si.path
        assert_match /^Honore_Victorin_Daumier_Don_Qichotte_lisant_Don_Quichotte_Don_[a-f0-9]+\.jpg/, si.filename
        assert_equal 'daumier', si.source_id
        assert_instance_of Source, si.source
        assert_match /^http:\/\/localhost:47001\/rack-images\/daumier\/r140\/[a-zA-Z0-9\+\/]+\?_asd=[a-f0-9]+$/, si.image_url
      end
    end

    test 'it should ensure an image record' do
      upload = Upload.first
      si = Pandora::SuperImage.new(upload.pid)
      assert_equal si.image, upload.image
      assert_match /^user_database_/, si.image.source.name

      si = Pandora::SuperImage.new('noexist-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')
      assert_raises ActiveRecord::RecordNotFound do
        si.image
      end

      si = Pandora::SuperImage.new('daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')
      assert_instance_of Image, si.image
      assert_equal 'daumier', si.image.source.name

      # simulate missing source
      si.image.update_column :source_id, nil
      si = Pandora::SuperImage.new('daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')
      assert_instance_of Image, si.image
      assert_equal 'daumier', si.image.source.name
    end
  end

  test 'exif extraction' do
    upload = create_upload 'skull'
    si = Pandora::SuperImage.new(upload.pid)

    # We need to ensure predictable image data, so we stub the image_data method
    data = File.read("#{Rails.root}/test/fixtures/files/skull.jpg")
    si.stub :image_data, data do
      assert_equal 'E', si.exif.gps_longitude_ref
    end
  end

  if production_sources_available?
    test 'it should ensure an image record avoiding race condition' do
      # we add a delay after Image.find_by to provoke a race condition which is
      # now handled by explicit locking

      original = Image.method(:find_by)
      test_implementation = lambda do |*args|
        result = original.call(*args)
        sleep 0.1
        result
      end

      Image.stub :find_by, test_implementation do
        a = Pandora::SuperImage.new('daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')
        b = Pandora::SuperImage.new('daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')

        t1 = Thread.new { a.image }
        t2 = Thread.new { b.image }

        t1.join
        t2.join

        assert_equal t1.value, t2.value
      end
    end

    test 'it should return a txt representation of an image' do
      si = Pandora::SuperImage.new(
        'daumier-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6'
      )
      text = "Artist: Honoré Victorin Daumier\n\nTitle: Don Qichotte lisant"
      assert_match text, si.to_txt

      upload = Upload.first
      si = Pandora::SuperImage.new(upload.pid)
      text = "Pid: upload-356a192b7913b04c54574d18c28d46e6395428ab\n\nVotes: 0"
      assert_match text, si.to_txt
    end
  end
end
