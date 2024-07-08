require "application_system_test_case"

class HelpTest < ApplicationSystemTestCase
  test 'all help should be available in English' do
    visit '/'

    within('#statusbar'){click_on 'Help'}
    assert_no_text 'Managing your personal account'
    assert_no_text 'Administrator management'

    login_as 'superadmin'
    within('#statusbar'){click_on 'Help'}

    assert_text 'Managing your personal account'
    assert_text 'Administrator management'

    tests = [
      # TODO: change to the page's header once corrected
      ['Signup', 'Fill in the registration form'],
      ['Login', 'Login help'],
      ['Search', 'Search help'],
      ['Query syntax', 'Syntax help'],
      ['Results list', 'Results help'],
      ['Copyright and publication', 'Copyright and publication help'],
      ['Collection', ''],
      ['My Uploads', 'Uploads help'],
      ['Sidebar', 'Sidebar help'],
      ['Administration', 'Administration help'],
      ['Managing your personal account', 'Managing your personal account'],
      ['Administrator management', 'Administrator management'],
      ['Profile', 'Profile help']
    ]

    tests.each do |t|
      within('#statusbar'){click_on 'Help'}
      within '#content' do
        click_on t[0]
        # assert_no_text
        assert_text t[1]
      end
    end
  end
end
