require "application_system_test_case"

class ImagesDirTest < ApplicationSystemTestCase
  if production_sources_available?
    test 'source upstream images should be removed' do
      ENV['PM_USE_TEST_IMAGE'] = "false"
      source_name = 'daumier'

      login_as 'jdoe'

      find_link('Advanced search').find('div').click

      fill_in 'search_value_0', with: 'baum'
      submit

      Pandora::ImagesDir.new.delete_upstream_images(source_name)

      assert_equal true, File.directory?("#{ENV['PM_IMAGES_DIR']}/#{source_name}/")
      assert_equal 0, Dir["#{ENV['PM_IMAGES_DIR']}/#{source_name}/*"].length
      assert_not_equal 0, Dir["#{ENV['PM_IMAGES_DIR']}/robertin/*"].length

      ENV['PM_USE_TEST_IMAGE'] = "true"
    end
  end
end
