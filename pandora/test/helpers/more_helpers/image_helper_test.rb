require 'test_helper'

class ImageHelperTest  < ActiveSupport::TestCase

  include MoreHelpers::ImageHelper

  if production_sources_available?
    test 'hover_over_image_title' do
      si = Pandora::SuperImage.new('robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc')
      image_title = hover_over_image_title(si)
      assert image_title == 'Torpedo-Maler (reifere Phase): Fischteller, campanisch, rotfigurig, Halle/Saale ROBERTINUM, Archäologisches Museum der Universität Halle'

      upload = Upload.find_by! title: 'A upload'
      image = upload.image
      si = Pandora::SuperImage.from(image)
      image_title = hover_over_image_title(si)
      assert_match 'Jean-Baptiste Dupont: A upload, Köln', image_title
    end
  end
end
