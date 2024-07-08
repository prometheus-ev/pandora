require "application_system_test_case"

class KeywordsTest < ApplicationSystemTestCase
  test 'create a keyword' do
    login_as 'superadmin'

    visit '/en/keywords'
    click_on 'Create a new keyword'
    fill_in 'Title (en)', with: ' Bäume'
    fill_in 'Title (de)', with: 'trees '
    click_on 'swap'
    submit
    assert_text 'successfully created'

    assert_equal 'trees', Keyword.last.title
    assert_equal 'Bäume', Keyword.last.title_de
  end

  test 'update a keyword' do
    login_as 'superadmin'

    visit '/en/keywords'
    within 'tr', text: 'Archaeology' do
      click_on 'Edit'
    end
    fill_in 'Title (de)', with: 'Archäologie'
    submit
    assert_text 'successfully updated'
    assert_equal 'Archäologie', Keyword.find_by!(title: 'archaeology').title_de
  end

  test 'delete a keyword' do
    login_as 'superadmin'

    visit '/en/keywords'
    within 'tr', text: 'Archaeology' do
      accept_confirm do
        click_on 'Delete'
      end
    end
    assert_text 'successfully deleted'
    assert_not Keyword.exists?(title: 'archaeology')
  end

  test 'empty keywords dont render an url' do
    # we prepare an institutional upload to test its rendering as a search
    # result
    jdoe = Account.find_by(login: "jdoe")
    jdoe.roles.push(Role.find_by(title: 'dbadmin'))
    jdoe.save!
    database = institutional_upload_source([jdoe])
    upload = institutional_upload(
      database,
      "galette",
      title: 'my-upload',
      keywords: [Keyword.find_by!(title: 'painting')]
    )
    Keyword.
      where(title: ['painting', 'archaeology', 'art history', 'italy 1988']).
      update_all title: nil
    database.index

    login_as 'jdoe'
    visit "/en/image/#{Upload.last.pid}"
    assert_no_text "field=keywords"

    visit "/en/collections"
    assert_no_text "field=keywords"

    visit '/en/searches?search_value=my-upload'
    assert_no_text "field=keywords"

    login_as 'superadmin'
    visit "/en/sources"
    assert_no_text "field=keywords"
  end
end
