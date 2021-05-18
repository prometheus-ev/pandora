require 'test_helper'
require 'test_sources/test_source_with_record_image_without_file_extension'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  test 'redirect legacy show urls' do
    get '/image/show/dresden-20c0fd3be2bf47556717e2de0ecccb31f7e92564'
    assert_redirected_to '/image/dresden-20c0fd3be2bf47556717e2de0ecccb31f7e92564'
  end

  if production_sources_available?
    test "should get download" do
      login_as 'jdoe'
      get "/en/image/download.zip?id=robertin-d8f0b98afb49373f88c11a7736745a146ff5b910"

      assert_response :success
      assert_equal "application/zip", @response.header["Content-Type"]

      file = File.open("tmp/download.zip", "w")
      file.puts @response.body
      file.close

      Zip::File.open('tmp/download.zip') do |zip_file|
        assert_equal 2, zip_file.size
        assert zip_file.get_entry("Alabastron_korinthisch_Sirene_Halle_Saale_ROBERTINUM_Archaeologisches_6ff5b910.jpg")
      end
    end
  end

  test "should get download including an image file with jpg file extension" do
    TestSourceWithRecordImageWithoutFileExtension.index

    login_as 'jdoe'
    get "/en/image/download.zip?id=test_source_with_record_image_without_file_extension-356a192b7913b04c54574d18c28d46e6395428ab"

    assert_response :success
    assert_equal "application/zip", @response.header["Content-Type"]

    file = File.open("tmp/download.zip", "w")
    file.puts @response.body
    file.close

    Zip::File.open('tmp/download.zip') do |zip_file|
      assert_equal 2, zip_file.size
      assert zip_file.get_entry("Artist_1_Title_1_Location_1_395428ab.jpg")
    end
  ensure
    Indexing::Index.delete("test*")
  end
end
