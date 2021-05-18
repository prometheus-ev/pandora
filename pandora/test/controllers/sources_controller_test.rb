require 'test_helper'

class SourcesControllerTest < ActionDispatch::IntegrationTest

  test 'dbadmin can only edit own sources' do
    jdoe = Account.find_by! login: 'jdoe'
    dbadmin = Role.find_by! title: "dbadmin"
    jdoe.update! roles: (jdoe.roles << dbadmin)

    daumier = Source.find_by! name: "daumier"
    daumier.update! source_admins: [jdoe]

    login_as 'jdoe'

    get '/en/sources/daumier'
    assert_select 'a[title="Edit"]'

    get '/en/sources/daumier/edit'
    assert_response :success

    get '/en/sources/robertin'
    assert_select 'a[title="Edit"]', false

    get '/en/sources/robertin/edit'
    assert_redirected_to '/en/login'

    follow_redirect!
    assert_match /You don't have privileges to access this/, flash[:warning]
  end

  test 'no duplicates in suggested keywords' do
    source = Source.find_by(name: 'daumier')
    source.keywords << Keyword.find_by!(title: 'Archaeology')

    login_as 'superadmin'

    get '/en/sources/suggest_keywords'
    assert_equal 1, response.body.scan(/Archaeology/).size
  end

end
