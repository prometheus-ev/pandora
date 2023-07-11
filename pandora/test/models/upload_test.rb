require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  test 'mime type to filename extension lookup' do
    assert_equal :gif, Mime::Type.lookup('image/gif').symbol
    assert_equal :png, Mime::Type.lookup('image/png').symbol

    assert_equal :jpg, Mime::Type.lookup('image/jpeg').symbol
    assert_equal :jpg, Mime::Type.lookup('image/pjpeg').symbol
    assert_equal :png, Mime::Type.lookup('image/x-png').symbol
  end

  test 'test creation of a new upload with validations' do
    path = "#{Rails.root}/test/fixtures/files/skull.jpg"
    file = Rack::Test::UploadedFile.new(path, 'image/jpeg')
    upload = Upload.new(file: file)

    assert_not upload.valid?
    assert_equal 75292, upload.file_size
    assert_equal 'jpg', upload.filename_extension

    jdoe = Account.find_by!(login: 'jdoe')
    upload.assign_attributes(
      database: jdoe.database,
      title: 'Skull',
      rights_work: 'John Doe',
      rights_reproduction: "John Doe"
    )

    # We need to make sure the test doesn't depend on rack-image's state, so we
    # return a forged Pandora::SuperImage on :initialize which returns
    # predictable image data
    oi = Pandora::SuperImage.method(:new)
    ti = lambda do |*args|
      super_image = oi.call(*args)
      def super_image.image_data(resolution = :small)
        File.read("#{Rails.root}/test/fixtures/files/skull.jpg")
      end
      super_image
    end
    Pandora::SuperImage.stub :new, ti do
      assert upload.save
      assert upload.image
    end

    assert_equal upload.image_id, upload.image.id
    assert_equal upload.pid, upload.image.pid
    assert_equal 75292, upload.file.size
    assert_in_delta 59.42, upload.latitude, 0.01
    assert_in_delta 24.8, upload.longitude, 0.01

    # updating the record should not create another image (so this should not
    # throw a Mysql2::Error: Duplicate entry)
    upload.update title: 'Pretty Skull'
  end

  test 'not accepted content type' do
    path = "#{Rails.root}/test/fixtures/files/skull.jpg"
    file = Rack::Test::UploadedFile.new(path, 'image/bmp')
    upload = Upload.new(file: file)

    upload.valid?
    assert_match /This file format is not supported/, upload.errors[:file].first
  end

  test 'permissions' do
    jdoe = Account.find_by!(login: 'jdoe')
    upload = Upload.find_by! title: 'A upload'

    assert_not_nil Upload.allowed(jdoe, :write).find_by(id: upload.id)
  end

  test 'keyword handling' do
    upload = Upload.new

    upload.keyword_list = "some\nthing\nnew"
    assert_equal 3, upload.keywords.size
    assert_equal "some\nthing\nnew", upload.keyword_list

    upload.keyword_list = "dark\nmatter"
    assert_equal 2, upload.keywords.size
    assert_equal "dark\nmatter", upload.keyword_list

    upload.keywords = [
      Keyword.find_or_create_by!(title: 'clear'),
      Keyword.find_or_create_by!(title: 'skies'),
    ]
    assert_equal "clear\nskies", upload.keyword_list
  end

  test 'create keywords in current locale' do
    upload = Upload.new

    upload.assign_attributes keyword_list: 'sun, sky'
    assert_equal 'sun', upload.keywords[0].title
    assert upload.keywords[0].title_de.blank?
    assert_equal 'sky', upload.keywords[1].title
    assert upload.keywords[1].title_de.blank?

    with_locale :de do
      upload.assign_attributes keyword_list: 'sonne, himmel'
      assert upload.keywords[0].title.blank?
      assert_equal 'sonne', upload.keywords[0].title_de
      assert upload.keywords[1].title.blank?
      assert_equal 'himmel', upload.keywords[1].title_de
    end
  end

  test 'file overwrite and delete' do
    with_env 'PM_USE_TEST_IMAGE' => 'false' do
      upload = create_upload('mona_lisa')

      # created
      si = Pandora::SuperImage.from(upload)
      assert File.exist?(si.original_file_path)
      assert_equal 71658, File.size(si.original_file_path)
      initial_size = si.image_data(:small).size
      small = "#{ENV['PM_IMAGES_DIR']}/upload/r140/#{si.pid}.jpg"
      assert File.exist?(small)

      # updated
      file = Rack::Test::UploadedFile.new(
        "#{Rails.root}/test/fixtures/files/galette.jpg",
        'image/jpeg'
      )
      si.upload.update file: file
      assert_equal 128637, File.size(si.original_file_path) # => not 71658, so different file
      assert_not_equal initial_size, si.image_data(:small).size # => not 4136, so different file
      assert File.exist?(small)

      # destroyed
      si.upload.destroy
      assert_not File.exist?(si.original_file_path)
      assert_not File.exist?(small)
    end
  end
end
