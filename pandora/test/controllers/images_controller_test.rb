require 'test_helper'
require 'test_sources/test_source_with_record_image_without_file_extension'
require 'test_sources/test_source'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  test 'redirect legacy show urls' do
    get '/image/show/dresden-20c0fd3be2bf47556717e2de0ecccb31f7e92564'
    assert_redirected_to '/image/dresden-20c0fd3be2bf47556717e2de0ecccb31f7e92564'
  end

  test "should get download" do
    TestSource.index
    file = "#{Rails.root}/tmp/test/images/test_source/original/path1.jpg"
    system 'mkdir', '-p', File.dirname(file)
    system(
      'cp', '-f',
      "#{Rails.root}/test/fixtures/files/skull.jpg",
      file
    )

    login_as 'jdoe'
    pid = Pandora::SuperImage.pid_for('test_source', 1)
    get "/en/image/download.zip?id=#{pid}"

    assert_response :success
    assert_equal "application/zip", @response.header["Content-Type"]

    file = File.open("tmp/download.zip", "w")
    file.puts @response.body
    file.close

    Zip::File.open('tmp/download.zip') do |zip_file|
      assert_equal 2, zip_file.size
      assert zip_file.get_entry("Raphael_Katze_auf_Stuhl_Florenz_395428ab.jpg")
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

  test "should get download a record with object ID count" do
    TestSource.index

    login_as 'jdoe'
    get "/en/image/download.zip?id=test_source-356a192b7913b04c54574d18c28d46e6395428ab"

    assert_response :success
    assert_equal "application/zip", @response.header["Content-Type"]

    file = File.open("tmp/download.zip", "w")
    file.puts @response.body
    file.close

    Zip::File.open('tmp/download.zip') do |zip_file|
      filename = 'Raphael_Katze_auf_Stuhl_Florenz_395428ab.txt'
      filepath = "tmp/#{filename}"
      assert_equal 2, zip_file.size

      entry = zip_file.get_entry(filename)
      File.delete(filepath) if File.exist?(filepath)
      entry.extract(filepath)

      File.readlines(filepath).each do |line|
        if (roic = line.split(':'))[0] == 'Record Object Id Count'
          assert_equal '2', roic[1].strip
        end
      end

      File.delete(filepath) if File.exist?(filepath)
    end
  ensure
    Indexing::Index.delete("test*")
  end

  test "should return proper 404" do
    get '/de/image/large/favicon.ico'
    assert_response :unauthorized # 401
  end
end
