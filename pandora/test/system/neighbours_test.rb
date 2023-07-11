require "application_system_test_case"

class NeighboursTest < ApplicationSystemTestCase
  test 'image has neighbourhood' do
    TestSource.index

    login_as 'jdoe'
    within '#menu' do
      click_on 'Search'
    end
    fill_in 'search_value_0', with: "stuhl"
    
    find('.submit_button').click
    assert_equal('/en/searches', page.current_path)

    click_on 'Katze auf Stuhl'
    assert_equal("/en/image/#{pid_for(1)}", page.current_path)
    assert_no_selector('.image_navigation a > img[title="Previous image"]')
    assert_selector('.image_navigation a > img[title="Back to searches"]')
    assert_selector('.image_navigation a > img[title="Next image"]')

    find('.image_navigation a > img[title="Next image"]').find(:xpath, "..").click
    assert_equal("/en/image/#{pid_for(3)}", page.current_path)
    assert_selector('.image_navigation a > img[title="Previous image"]')

    find('.image_navigation a > img[title="Back to searches"]').find(:xpath, "..").click
    assert_equal('/en/searches', page.current_path)
  end
end
