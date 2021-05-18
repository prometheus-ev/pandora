require 'test_helper'

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "legacy presentation download, including permission denied" do
    jdoe = Account.find_by! login: 'jdoe'
    mrossi = Account.find_by! login: 'mrossi'

    login_as 'jdoe'

    url_opts = {id: jdoe.id, presentation_id: 1, presentation_filename: 'empty.pdf', locale: 'en'}
    get download_legacy_presentation_path(url_opts), as: :pdf
    assert_response :success

    login_as 'mrossi'
    get download_legacy_presentation_path(url_opts), as: :pdf
    assert_redirected_to '/en/login'
    assert_equal 'You are not allowed to access this resource.', flash[:warning]
  end

  test 'update direction settings with invalid data' do
    jdoe = Account.find_by! login: 'jdoe'
    login_as 'jdoe'

    patch '/en/profile', params: {user: {collection_settings_attributes: {direction: 'danger!'}}}
    assert_match /There were some errors/, flash[:warning]
    patch '/en/profile', params: {user: {collection_settings_attributes: {direction: nil}}}
    assert_match /successfully updated/, flash[:notice]

    patch '/en/profile', params: {user: {search_settings_attributes: {direction: 'danger!'}}}
    assert_match /There were some errors/, flash[:warning]
    patch '/en/profile', params: {user: {search_settings_attributes: {direction: nil}}}
    assert_match /successfully updated/, flash[:notice]

    patch '/en/profile', params: {user: {upload_settings_attributes: {direction: 'danger!'}}}
    assert_match /There were some errors/, flash[:warning]
    patch '/en/profile', params: {user: {upload_settings_attributes: {direction: nil}}}
    assert_match /successfully updated/, flash[:notice]

    patch '/en/profile', params: {user: {account_settings_attributes: {direction: 'danger!'}}}
    assert_match /There were some errors/, flash[:warning]
    patch '/en/profile', params: {user: {account_settings_attributes: {direction: nil}}}
    assert_match /successfully updated/, flash[:notice]
  end
end
