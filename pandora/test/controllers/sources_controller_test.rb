require 'test_helper'

class SourcesControllerTest < ActionDispatch::IntegrationTest
  test 'dbadmin can only edit own sources' do
    TestSource.index
    TestSourceSorting.index

    jdoe = Account.find_by! login: 'jdoe'
    dbadmin = Role.find_by! title: "dbadmin"
    jdoe.update! roles: (jdoe.roles << dbadmin)

    test_source = Source.find_by! name: "test_source"
    test_source.update! source_admins: [jdoe]

    login_as 'jdoe'

    get '/en/sources/test_source'
    assert_select 'a[title="Edit"]'

    get '/en/sources/test_source/edit'
    assert_response :success

    get '/en/sources/test_source_sorting'
    assert_select 'a[title="Edit"]', false

    get '/en/sources/test_source_sorting/edit'
    assert_redirected_to '/en/login'

    follow_redirect!
    assert_match /You don't have privileges to access this/, flash[:warning]

    Pandora::Elastic.new.destroy_alias('test_source')
  end
end
