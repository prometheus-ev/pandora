require 'test_helper'

class ImageRequestTest < ActionDispatch::IntegrationTest
  test 'image from non existing source' do
    get '/en/image/no_exist-cc4ba69925f263ef64904360aa469db335e7c07a', headers: api_auth('jdoe')
    assert_match /File not found/, response.body

    get '/de/image/no_exist-cc4ba69925f263ef64904360aa469db335e7c07a', headers: api_auth('jdoe')
    assert_match /Datei nicht gefunden/, response.body
  end

  test 'non existing images' do
    pids = ["robertin-xxx", "robertinxxx", "upload-xxx", "upload-", "-xxx", "xxx"]
    pids.each do |pid|
      get "/en/image/#{pid}", headers: api_auth('jdoe')
      assert_response :missing
    end
  end

  test 'handle multi-frame media (video)' do
    restore_images_dir

    file = Rack::Test::UploadedFile.new(
      "#{Rails.root}/test/fixtures/files/forest.mp4",
      'video/mp4'
    )
    upload = create_upload(file, title: 'Forest')

    with_env 'PM_USE_TEST_IMAGE' => 'false' do
      # we download the original and check its size and content_type
      si = Pandora::SuperImage.from(upload)
      get(si.image_url(:original))
      assert_equal 'video/mp4', response.content_type
      assert_equal 3149896, response.body.bytesize
    end
  end

  test 'handle multi-frame media (pdf)' do
    restore_images_dir

    file = Rack::Test::UploadedFile.new(
      "#{Rails.root}/test/fixtures/files/text.pdf",
      'application/pdf'
    )
    upload = create_upload(file, title: 'Lorem ipsum')

    with_env 'PM_USE_TEST_IMAGE' => 'false' do
      # we download the original and check its size and content_type
      si = Pandora::SuperImage.from(upload)
      get(si.image_url(:original))
      assert_equal 'application/pdf', response.content_type
      assert_equal 52303, response.body.bytesize
    end
  end

  test 'handle multi-frame media (animated gif)' do
    restore_images_dir

    file = Rack::Test::UploadedFile.new(
      "#{Rails.root}/test/fixtures/files/animation.gif",
      'image/gif'
    )
    upload = create_upload(file, title: 'Animation')

    with_env 'PM_USE_TEST_IMAGE' => 'false' do
      # we download the original and check its size and content_type
      si = Pandora::SuperImage.from(upload)
      get(si.image_url(:original))
      assert_equal 'image/gif', response.content_type
      assert_equal 984299, response.body.bytesize
    end
  end
end