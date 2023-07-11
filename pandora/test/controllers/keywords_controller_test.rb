require 'test_helper'

class KeywordsControllerTest < ActionDispatch::IntegrationTest
  test 'no duplicates in suggested keywords' do
    source = Source.find_by(name: 'test_source')
    source.keywords << Keyword.find_by!(title: 'Archaeology')

    login_as 'superadmin'

    get '/en/keywords/suggest'
    assert_equal 1, response.body.scan(/Archaeology/).size
  end

  test 'no access for non-admins' do
    login_as 'jdoe'
    
    get '/en/keywords'
    assert_redirected_to login_path
  end
end
