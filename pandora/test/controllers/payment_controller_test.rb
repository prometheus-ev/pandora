require 'test_helper'

class PaymentControllerTest < ActionDispatch::IntegrationTest
  test 'paypal ipn backchannel confirmation' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_column :mode, 'paypal'
    pt = PaymentTransaction.transaction_for(jdoe)

    post '/en/payment/paypal_ipn', params: {invoice: pt.id}
    assert_response :success

    post '/payment/paypal_ipn', params: {invoice: pt.id}
    assert_response :success

    # paypal sends invald http requests, so we check that we can deal with it
    bogus = 'Schloß'.encode('iso-8859-1')
    post '/de/payment/paypal_ipn', params: {invoice: pt.id, value: bogus}
    assert_response :success
  end
end