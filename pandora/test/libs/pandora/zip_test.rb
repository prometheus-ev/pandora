require 'test_helper'

class ZipTest < ActiveSupport::TestCase
  test 'should package database.yml.example' do
    zip = Pandora::Zip.new('db.yml' => File.open("#{Rails.root}/config/database.yml.example"))

    test_zip = "#{Rails.root}/tmp/test.zip"
    File.open test_zip, 'wb' do |f|
      f.write zip.generate
    end

    # The generate method has returned and the result was streamed to a file so
    # the child process shouldn't exist anymore
    assert_raise Errno::ESRCH do
      Process.kill 0, zip.pid
    end

    listing = `unzip -l #{test_zip}`
    assert_match /db\.yml/, listing
  end
end