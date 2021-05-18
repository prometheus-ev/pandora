require 'test_helper'

class AuthTest < ActionDispatch::IntegrationTest
  test 'xhr redirect' do
    # this case is probably triggered by expired sessions with remaining open
    # browser tabs
    get '/en/image/dresden-c80ee9bef01fcb83601cafec66bf8a3fb15f0433?box_id=sidebar_box-15348', xhr: true
    assert_equal 'text/javascript', response.content_type
    assert_match /location.href/, response.body
  end

  if ENV['PM_BRITTLE']=='true'
    # brittle because the hostname resolution requires working DNS
    test 'campus auth via hostname instead of ip (for dyndns & friends)' do
      nowhere = Institution.find_by!(name: 'nowhere')
      nowhere.update(ipranges: '')

      # make sure we are coming in with the right ip
      cookies['test_key'] = '_test_cookies'
      get '/en/campus', headers: {'REMOTE_ADDR' => '95.217.4.161'}
      follow_redirect!
      assert_match "Sorry, your IP address 95.217.4.161 doesn't match", response.body

      # test with hostname allowed
      nowhere.update(hostnames: 'wendig.io')
      # cookies['test_key'] = '_test_cookies'
      get '/en/campus', headers: {'REMOTE_ADDR' => '95.217.4.161'}
      follow_redirect!
      assert_redirected_to '/en/searches'
    end
  end
end