require 'test_helper'

class JsControllerTest < ActionDispatch::IntegrationTest
  test 'generate pandora.js for prometheus-bildarchiv.de' do
    get '/en/pandora.js'
    assert response.successful?

    # should also work when logged in
    login_as 'jdoe'
    get '/en/pandora.js'
    assert response.successful?
  end
end