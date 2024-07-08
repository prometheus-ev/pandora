require 'test_helper'

class ApiFormatTest < ActionDispatch::IntegrationTest
  test 'should recognize json format from the url' do
    assert_recognizes(
      {
        api_version: 'v1',
        controller: 'images',
        action: 'show',
        id: 'daumier-1234',
        format: 'json'
      },
      '/api/json/image/show/daumier-1234'
    )
  end

  test 'should recognize xml format from the url' do
    assert_recognizes(
      {
        api_version: 'v1',
        controller: 'images',
        action: 'show',
        id: 'daumier-1234',
        format: 'xml'
      },
      '/api/xml/image/show/daumier-1234'
    )
  end

  test 'should recognize blob format from the url' do
    assert_recognizes(
      {
        api_version: 'v1',
        controller: 'images',
        action: 'show',
        id: 'daumier-1234',
        format: 'blob'
      },
      '/api/blob/image/show/daumier-1234'
    )
  end
end
