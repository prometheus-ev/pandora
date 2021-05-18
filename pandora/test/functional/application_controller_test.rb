require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  test 'translate with link' do
    def tl(string, url_options = nil, interpolations = [])
      @controller.send(:translate_with_link, string, url_options, interpolations)
    end

    url = 'https://prometheus-bildarchiv.de'
    out = tl("Please contact the %{prometheus office}%.", url)
    assert_equal "Please contact the <a href=\"#{url}\">prometheus office</a>.", out
    assert out.html_safe?

    url = 'https://prometheus-bildarchiv.de'
    out = tl("Please %s the %{prometheus office}%.", url, 'contact')
    assert_equal "Please contact the <a href=\"#{url}\">prometheus office</a>.", out
    assert out.html_safe?

    out = tl("Please contact the %{prometheus office}%.")
    assert_equal "Please contact the <a href=\"/en\">prometheus office</a>.", out
    assert out.html_safe?

    out = tl("About %s", nil, 'images')
    assert_equal "About images", out
    assert out.html_safe?

    out = tl("About")
    assert_equal "About", out
    assert out.html_safe?
  end
end
