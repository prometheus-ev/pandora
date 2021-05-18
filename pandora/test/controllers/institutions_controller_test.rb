require 'test_helper'

class InstitutionsControllerTest < ActionDispatch::IntegrationTest
  test 'should handle names with special characters' do
    assert_recognizes(
      {
        controller: 'institutions',
        action: 'show',
        locale: 'en',
        id: 'nuernberg_museum_germ.nat.'
      },
      '/en/institutions/nuernberg_museum_germ.nat.'
    )
  end

  test "redirect from index to user's institution" do
    jdoe = Account.find_by! login: 'jdoe'

    login_as 'jdoe'
    get '/en/institutions'
    assert_redirected_to "/en/institutions/#{jdoe.institution.name}"

    # we expect no error
    follow_redirect!
  end
end