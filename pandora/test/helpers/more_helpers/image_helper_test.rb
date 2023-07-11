require 'test_helper'

class ImageHelperTest  < ActiveSupport::TestCase

  include MoreHelpers::ImageHelper

  test 'hover_over_image_title' do
    TestSource.index

    si = Pandora::SuperImage.new(pid_for(1))
    image_title = hover_over_image_title(si)
    assert_equal 'Raphael: Katze auf Stuhl, Florenz', image_title

    upload = Upload.find_by! title: 'A upload'
    image = upload.image
    si = Pandora::SuperImage.from(image)
    image_title = hover_over_image_title(si)
    assert_match 'Jean-Baptiste Dupont: A upload, Köln', image_title
  end
end
