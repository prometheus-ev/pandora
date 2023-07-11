require "application_system_test_case"

class ImagesDirTest < ApplicationSystemTestCase
  # can't be tested without external dependencies
  # test 'source upstream images should be removed' do
  #   binding.pry

  #   with_env 'PM_USE_TEST_IMAGE' => 'false' do
  #     source_name = 'test_source'

  #     data_dir = "#{ENV['PM_IMAGES_DIR']}/test_source"
  #     system 'mkdir', '-p', "#{data_dir}/original/images"
  #     system('cp',
  #       "#{Rails.root}/test/fixtures/files/skull.jpg",
  #       "#{data_dir}/original/images/sample.jpg"
  #     )

  #     resizer = RackImages::Resizer.new
  #     resizer.run('/test_source/r140/images/sample.jpg')

  #     Pandora::ImagesDir.new.delete_upstream_images(source_name)

  #     assert_equal true, File.directory?("#{ENV['PM_IMAGES_DIR']}/#{source_name}")
  #     binding.pry

  #     assert_equal 0, Dir["#{ENV['PM_IMAGES_DIR']}/#{source_name}/*"].length
  #   end
  # end
end
