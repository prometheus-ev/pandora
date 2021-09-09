require "application_system_test_case"

class AnnouncementsTest < ApplicationSystemTestCase

  setup do
    Announcement.all.each{|n| n.destroy}
  end

  test 'create and delete an announcement' do
    login_as 'superadmin'

    click_on 'Administration'
    section = find('h3', text: 'Announcement').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'List'
    assert_text 'No announcement found'

    find('.plus_button').click
    fill_in 'Title [German]', with: 'Jetzt auch mit Bitcoin bezahlen!'
    fill_in 'Title [English]', with: 'We now support bitcoin payments!'
    fill_in 'Body [German]', with: 'irgendein Text'
    fill_in 'Body [English]', with: 'some text'

    # make sure the preset start/end is in local time
    value = Time.mktime(
      *all("select[id*='announcement_starts_at_']").map{|s| s.value}
    )
    assert_in_delta value, 1.week.from_now, 1.minute

    select Time.now.year + 1, from: 'announcement_ends_at_1i'
    choose 'users'
    submit

    assert_text 'Preview [English]'

    click_on 'Log out'
    assert_no_text 'bitcoin'

    travel 2.weeks do
      login_as 'jdoe'
      within '#sidebar' do
        assert_text 'bitcoin'
        # this element is a div within a div within an a and with chrome headless
        # the div doesn't bubble up the click, we therefore have to run the test
        # with a real browser
        find('.collapse').click
        assert_no_text 'bitcoin'
        find('.expand').click
        assert_text 'bitcoin'
        find('.open').click
      end

      within '#main' do
        assert_text 'bitcoin'
      end

    end

    click_on 'Log out'
    travel_to 13.months.from_now do
      login_as 'jdoe'
      assert_no_text 'bitcoin'
    end

    travel 2.weeks do
      # check rendering in German
      click_on 'Deutsch'
      within '#sidebar' do
        assert_text 'Jetzt auch mit Bitcoin bezahlen!'
      end
      click_on 'English'

      # close announcement
      within '#sidebar' do
        assert_text 'News'
        find('.close').click
        assert_no_text 'News'

        reload_page
        assert_no_text 'News'
      end
    end
  end

  test 'publish and withdraw an announcement' do
    login_as 'superadmin'

    click_on 'Administration'
    section = find('h3', text: 'Announcement').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'List'
    assert_text 'No announcement found'

    find('.plus_button').click
    fill_in 'Title [German]', with: 'Jetzt auch mit Bitcoin bezahlen!'
    fill_in 'Title [English]', with: 'We now support bitcoin payments!'
    fill_in 'Body [German]', with: 'irgendein Text'
    fill_in 'Body [English]', with: 'some text'
    select Time.now.year + 1, from: 'announcement_ends_at_1i'
    choose 'users'
    submit

    logout

    travel 2.weeks

    login_as 'jdoe'
    within '#sidebar' do
      assert_text 'bitcoin'
      find('.close').click
      assert_no_text 'bitcoin'
    end

    logout

    login_as 'superadmin'
    click_on 'Administration'
    section = find('h3', text: 'Announcement').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'List'
    click_on 'Edit'
    fill_in 'Body [German]', with: 'Zahlen Sie schnell bevor die Kurse fallen!'
    fill_in 'Body [English]', with: 'Don\'t wait to long The market price is falling!.'
    submit

    logout

    login_as 'jdoe'
    within '#sidebar' do
      assert_no_text 'bitcoin'
      assert_no_text 'falling'
    end
    logout

    travel 1.week

    login_as 'superadmin'
    click_on 'Administration'
    section = find('h3', text: 'Announcement').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'List'
    click_on 'We now support bitcoin payments!'

    click_on 'Republish now!'
    assert_text 'successfully published'

    logout

    travel 1.day
    # it was republished so we should see it again
    login_as 'jdoe'
    within '#sidebar' do
      assert_text 'bitcoin'
      assert_text 'falling'
    end
    logout

    login_as 'superadmin'
    click_on 'Administration'
    section = find('h3', text: 'Announcement').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'List'
    click_on 'We now support bitcoin payments!'

    click_on 'Withdraw now!'
    assert_text 'successfully withdrawn'

    logout

    login_as 'jdoe'
    within '#sidebar' do
      assert_no_text 'bitcoin'
    end
  end

  # test 'minimize announcement'
  # test 'hide announcements'
end