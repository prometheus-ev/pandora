require 'test_helper'

class RackImages::ResizerTest < ActiveSupport::TestCase
  setup do
    restore_images_dir
    system 'mkdir', '-p', "#{data_dir}/original/images"
  end

  def data_dir
    "#{ENV['PM_IMAGES_DIR']}/test_source"
  end

  test 'resize jpg' do
    system(
      'cp',
      "#{Rails.root}/test/fixtures/files/skull.jpg",
      "#{data_dir}/original/images/sample.jpg"
    )

    resizer = RackImages::Resizer.new
    resizer.run('/test_source/r140/images/sample.jpg')

    assert_equal 'image/jpeg', mime_type_for("#{data_dir}/r140/images/sample.jpg")
    assert_in_delta 5458, File.size("#{data_dir}/r140/images/sample.jpg"), 500
  end

  test 'extract first frame from gif' do
    system(
      'cp',
      "#{Rails.root}/test/fixtures/files/animation.gif",
      "#{data_dir}/original/images/sample.gif"
    )

    resizer = RackImages::Resizer.new
    resizer.run('/test_source/r140/images/sample.gif')

    assert_in_delta 7743, File.size("#{data_dir}/r140/images/sample.jpg"), 500
  end

  # See #1726.
  test "extract first page from pdf" do
    system(
      'cp',
      "#{Rails.root}/test/fixtures/files/text.pdf",
      "#{data_dir}/original/images/sample.pdf"
    )

    resizer = RackImages::Resizer.new
    resizer.run('/test_source/r140/images/sample.pdf')

    # we convert to bmp to make the file size more reliable
    jpg = "#{data_dir}/r140/images/sample.jpg"
    bmp = "#{Rails.root}/tmp/test.bmp"
    Pandora.run('convert', jpg, bmp)

    mime = Pandora.run('file', '-ib', '--mime-type', bmp).split(';')[0]
    assert_equal 'image/bmp', mime
  end

  test 'extract first frame from mp4' do
    system(
      'cp',
      "#{Rails.root}/test/fixtures/files/forest.mp4",
      "#{data_dir}/original/images/sample.mp4"
    )

    resizer = RackImages::Resizer.new
    resizer.run('/test_source/r140/images/sample.mp4')

    identified = `identify #{data_dir}/r140/images/sample.jpg`
    assert_match(/ JPEG /, identified)
    assert_match(/ 140x74 /, identified)
  end
end
