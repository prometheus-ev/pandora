require "application_system_test_case"

class NeighboursTest < ApplicationSystemTestCase
  if production_sources_available?
    test 'image has neighbourhood' do
      login_as 'jdoe'
      within '#menu' do
        click_on 'Search'
      end
      fill_in 'search_value_0', with: "Torpedo"
      
      find('.submit_button').click
      assert_equal('/en/searches', page.current_path)

      find('.image_list div.image a', match: :first).click
      assert_equal('/en/image/robertin-2bb7a8b4c4c9db72ab6111dfa14e5101fa921980', page.current_path)
      assert_no_selector('.image_navigation a > img[title="Previous image"]')
      assert_selector('.image_navigation a > img[title="Back to searches"]')
      assert_selector('.image_navigation a > img[title="Next image"]')

      find('.image_navigation a > img[title="Next image"]').find(:xpath, "..").click
      assert_equal('/en/image/robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc', page.current_path)
      assert_selector('.image_navigation a > img[title="Previous image"]')

      find('.image_navigation a > img[title="Back to searches"]').find(:xpath, "..").click
      assert_equal('/en/searches', page.current_path)
    end
  end
end