require "application_system_test_case"

class SourcesTest < ApplicationSystemTestCase
  if production_sources_available?
    test 'search' do
      visit '/sources'

      assert has_select?('order', selected: 'Title')

      select 'Name', from: 'field'
      fill_in 'value', with: 'Robertin'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'Title', from: 'field'
      fill_in 'value', with: 'Daumier'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'Kind', from: 'field'
      fill_in 'value', with: 'Museum'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'City', from: 'field'
      fill_in 'value', with: 'Ascona'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'Country', from: 'field'
      fill_in 'value', with: 'Switzerland'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'Institution', from: 'field'
      fill_in 'value', with: 'Daumier'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'Description', from: 'field'
      fill_in 'value', with: 'Robertin'

      submit 'Search'
      assert_text 'Sources 1 of 1'

      select 'Keywords', from: 'field'
      fill_in 'value', with: 'Art history'

      submit 'Search'
      assert_text 'Sources 1 of 1'
    end
  end

  test 'list, sort and search' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Source' do
      click_on 'List'
    end

    within '.list_controls:nth-child(4)' do
      select 'Name', from: 'order'
    end
    within '.list_row:first-child' do
      assert_text 'Daumier'
    end

    within '.list_controls:nth-child(4)' do
      select 'Title', from: 'order'
    end
    within '.list_row:first-child' do
      assert_text 'Daumier Register'
    end

    within '.list_controls:nth-child(4)' do
      select 'Kind', from: 'order'
    end
    within '.list_row:first-child' do
      assert_text 'Museum database'
    end

    within '.list_controls:nth-child(4)' do
      select 'City', from: 'order'
    end
    within '.list_row:first-child' do
      assert_text 'Ascona'
    end

    within '.list_controls:nth-child(4)' do
      select 'Country', from: 'order'
    end
    within '.list_row:first-child' do
      assert_text 'Deutschland'
    end

    within '.list_controls:nth-child(4)' do
      select 'Institution', from: 'order'
    end
    within '.list_row:first-child' do
      assert_text 'Institution: Daumier Register'
    end

    within '.list_controls:nth-child(4)' do
      select 'Record count', from: 'order'
    end

    within '.list_row:first-child' do
      assert_text '0 image'
    end

    fill_in 'value', with: 'daumier'
    submit 'Search'
    assert_no_text 'ROBERTIN'
    assert_no_text 'User database'

    select 'Name', from: 'field'
    fill_in 'value', with: 'Köhler'

    submit 'Search'
    assert_text '0 Sources'

    within '.list_controls:nth-child(4)' do
      select 'Institution', from: 'order'
    end
    assert_text '0 Sources'
  end

  test 'create a source' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Source' do
      click_on 'Create'
    end

    fill_in 'Name', with: 'imdb'
    fill_in 'Title', with: 'Image DB Uni Mainz'
    select 'Nowhere, Nowhere University'
    fill_in 'Keywords', with: 'antique', wait: 5
    submit

    assert_text 'successfully created'
    source = Source.find_by!(name: 'imdb')
    assert_equal 'imdb', source.name
    assert_equal 'Image DB Uni Mainz', source.title
    assert_equal 'Nowhere University', source.institution.title
  end

  test 'create open access source' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Source' do
      click_on 'Create'
    end

    check 'Open Access?'
    submit
    assert_text 'Institution must exist'
    assert_field('Open Access?', checked: true)

    fill_in 'Name', with: 'nowhere'
    fill_in 'Title', with: 'Nowhere'
    select 'Nowhere, Nowhere University', from: 'Institution'
    fill_in 'Keywords', with: "some things\nsome things\n some things\nsmall"
    submit
    assert_text "Source 'nowhere' successfully created!"

    source = Source.find_by!(name: 'nowhere')
    assert_not_nil source.dbuser
    assert_equal "some things\nsmall", source.keyword_list

    click_on 'Edit'
    assert_field('Open Access?', checked: true)
    submit
    assert_text "Source 'nowhere' successfully updated!"

    # ensure there are not 2 dbusers for 'nowhere' now
    institution = Institution.find_by! name: 'nowhere'
    dbusers = Account.where(institution_id: institution.id, login: 'source')
    assert_equal 1, dbusers.count
  end

  test 'update a source (translated field)' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Source' do
      click_on 'List'
    end
    click_on 'ROBERTIN-database'
    click_on 'Edit'

    fill_in 'Description [English]', with: 'interesting'
    submit
    assert_text 'successfully updated'

    source = Source.find_by!(name: 'robertin')
    assert_equal 'interesting', source.description

    change_locale(:de)
    assert_css '.description-line', count: 0
  end

  if production_sources_available?
    test 'source ratings' do
      si = Pandora::SuperImage.new('daumier-cf03d626ef05e83c0b610b864a95f256dea8de2a')
      si.image.update({votes: 3}, without_protection: true)

      login_as 'superadmin'
      click_on 'Administration'
      within_admin_section 'Source' do
        click_on 'List'
      end
      within '.list_row:first-child .title-line' do
        click_on 'Daumier Register'
      end
      click_on '1 rating'
      assert_text 'Ratings for Source'
      assert_text 'Femme sous un arbre'
    end

    test 'show source info with contact having white space in login' do
      jdoe = Account.find_by(login: 'jdoe')
      robertin = Source.find_by(name: 'robertin')
      jdoe.update login: 'John Doe'
      robertin.update contact: jdoe

      login_as 'superadmin'
      click_on 'Administration'
      within_admin_section 'Source' do
        click_on 'List'
      end
      click_on 'ROBERTIN-database'

      assert_text 'Martin-Luther-Universität, Institut für Klassische Altertumswissenschaften'
    end
    
    test "set 'can_exploit_rights' flag and request rights" do
      login_as 'superadmin'

      login_as 'jdoe'
      fill_in 'search_value_0', with: 'baum'
      submit
      within '.list_row:nth-child(1)' do
        find("img[title='Copyright and publishing information']").find(:xpath, '..').click
      end
      assert_text 'cannot be obtained directly via prometheus'

      source = Source.find_by!(name: 'daumier')
      source.update_attributes!(
        can_exploit_rights: true,
        email: 'usage@example.com'
      )
      reload_page

      assert_text 'can be obtained directly via prometheus'

      choose 'type_scientific'
      choose 'mode_print'
      fill_in 'Information about the publication', with: 'I am writing a book'
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'
      fill_in 'E-mail', with: 'jdoe@example.com'
      fill_in 'Address', with: 'Am heißen Stein 12'
      fill_in 'Postal code', with: '43345'
      fill_in 'City', with: 'Freiburg'
      fill_in 'Country', with: 'Germany'
      submit
      assert_text 'Your inquiry has been delivered'

      request = ActionMailer::Base.deliveries[0]
      copy = ActionMailer::Base.deliveries[1]

      assert_match /Publikationsanfrage/, request.subject
      assert_includes request.to, 'usage@example.com'
      assert_match /Your publication inquiry/, copy.subject
      assert_includes copy.to, 'jdoe@example.com'
    end
  end


  # see #417, dropped
  # test 'validate a source'
end
