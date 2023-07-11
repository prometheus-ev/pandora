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

  test 'it should work for a elastic image' do
    TestSource.index

    with_real_images do
      pid = Pandora::SuperImage.pid_for('test_source', 1)
      si = Pandora::SuperImage.new(pid)

      assert_equal 'Raphael: Katze auf Stuhl (Florenz)', si.to_s
      assert_equal 'image/jpeg', si.mime_type.to_s
      assert_equal 'jpg', si.extension
      assert_match /path1.jpg/, si.path
      assert_match /^Raphael_Katze_auf_Stuhl_Florenz_395428ab.jpg$/, si.filename
      assert_equal 'test_source', si.source_id
      assert_instance_of Source, si.source
      assert_match /^http:\/\/localhost:47001\/rack-images\/test_source\/r140\/[a-zA-Z0-9\+\/]+\?_asd=[a-f0-9]+$/, si.image_url
    end
  end

  test 'it should ensure an image record' do
    TestSource.index

    upload = Upload.first
    si = Pandora::SuperImage.new(upload.pid)
    assert_equal si.image, upload.image
    assert_match /^user_database_/, si.image.source.name

    si = Pandora::SuperImage.new('noexist-8d04e65ebf6a7b73fb71a40d5b9fc226ee5dd3f6')
    assert_raises ActiveRecord::RecordNotFound do
      si.image
    end

    pid = Pandora::SuperImage.pid_for('test_source', 1)
    si = Pandora::SuperImage.new(pid)
    assert_instance_of Image, si.image
    assert_equal 'test_source', si.image.source.name

    # simulate missing source
    si.image.update_column :source_id, nil
    si = Pandora::SuperImage.new(pid)
    assert_instance_of Image, si.image
    assert_equal 'test_source', si.image.source.name
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

  test 'it should ensure an image record avoiding race condition' do
    TestSource.index
    # we add a delay after Image.find_by to provoke a race condition which is
    # now handled by explicit locking

    original = Image.method(:find_by)
    test_implementation = lambda do |*args|
      result = original.call(*args)
      sleep 0.1
      result
    end

    Image.stub :find_by, test_implementation do
      pid = Pandora::SuperImage.pid_for('test_source', 1)
      a = Pandora::SuperImage.new(pid)
      b = Pandora::SuperImage.new(pid)

      t1 = Thread.new { a.image }
      t2 = Thread.new { b.image }

      t1.join
      t2.join

      assert_equal t1.value, t2.value
    end
  end

  test 'it should return a txt representation of an image' do
    TestSource.index

    pid = Pandora::SuperImage.pid_for('test_source', 1)
    si = Pandora::SuperImage.new(pid)
    text = "Artist: Raphael\n\nTitle: Katze auf Stuhl\n\nLocation: Florenz"
    assert_match text, si.to_txt

    upload = Upload.first
    si = Pandora::SuperImage.new(upload.pid)
    text = "Pid: upload-356a192b7913b04c54574d18c28d46e6395428ab\n\nVotes: 0"
    assert_match text, si.to_txt
  end

  test 'returns correct source and pid for institutional uploads' do
    jdoe = Account.find_by(login: "jdoe")
    jdoe.roles << Role.find_by(title: 'dbadmin')
    source = institutional_upload_source([jdoe])
    upload = institutional_upload(source, 'galette')

    si = Pandora::SuperImage.from(upload)
    assert_equal upload.database, si.source
    assert_equal 'upload', si.source_id
    assert_equal 'prometheus', si.index_name
    assert_match /^upload-[a-f0-9]{40}/, si.pid
    assert_match /^prometheus-[a-f0-9]{40}/, si.index_record_id
  end

  test 'fails gracefully when indexing singular uploads' do
    upload = Upload.first
    upload.remove_index_doc

    assert_not upload.super_image.elastic_record['found']

    assert_nothing_raised do
      upload.super_image.remove_index_doc
    end
  end
end
