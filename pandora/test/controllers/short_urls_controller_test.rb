require 'test_helper'

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest

  test 'should redirect for existing ShortUrl' do
    target_url = url_for(
      locale: 'en',
      controller: 'images',
      action: 'show',
      id: 'robertin-b0d69964270fc26b071969fa28cd5933133e75cc'
    )

    short_url = ShortUrl.create url: target_url

    get "/en/u/#{short_url.token}"
    assert_redirected_to target_url
  end

  test 'should gracefully fail for non-existing ShortUrl' do
    get '/en/u/does-not-exist'
    assert_redirected_to '/en'
    assert_equal "The link with token 'does-not-exist' couldn't be found", flash[:error]
  end

end
