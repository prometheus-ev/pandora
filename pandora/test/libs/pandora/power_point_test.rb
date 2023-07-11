require 'test_helper'

class PowerPointTest < ActiveSupport::TestCase
  test 'it should build a presentation' do
    presentation = Pandora::PowerPoint.new [
      {
        title: 'Mona Lisa',
        path: 'test/fixtures/files/mona_lisa.jpg',
        meta: [
          'Born: 1982',
          'Died: June 2029',
          'oil on canvas'
        ]
      },
      {
        title: 'Leonardo',
        path: 'test/fixtures/files/leonardo.jpg'
      }
    ]

    presentation.save Rails.root.join('tmp/presentation.pptx')
    assert File.exist?(Rails.root.join('tmp/presentation.pptx'))
  end

  test 'from collection' do
    restore_images_dir

    collection = Collection.find_by! title: "John's private collection"
    collection.images << Upload.last.image
    collection.images << create_upload('galette').image

    # should also work without title
    Upload.last.update_column :title, nil
    # should also work when credits are available (as non-array)
    Upload.last.update_column :credits, 'unknown'
    
    collection.reload

    filename = Rails.root.join('tmp/presentation.pptx')
    presentation = Pandora::PowerPoint.from_collection(collection)
    presentation.save filename
    assert File.exist?(filename)
  end
end
