require 'test_helper'

class SourcesControllerTest < ActionDispatch::IntegrationTest
  test "mass editing without having selected uploads displays notice" do
    login_as 'jdoe'

    get '/en/uploads/edit_selected'
    assert_redirected_to '/en/uploads'

    follow_redirect!
    assert_equal "Select some objects first!", flash[:notice]
  end

  test 'a txt download' do
    login_as 'jdoe'

    jdoe = Account.find_by! login: 'jdoe'

    get '/en/image/download.zip', params: {id: jdoe.database.uploads.first.image.pid}
    assert_response :success
  end

  test 'unapproving uploads that are in collections' do
    priv = Collection.find_by! title: "John's private collection"
    pub = Collection.find_by! title: "John's public collection"
    collab = Collection.find_by! title: "John's collaboration collection"
    upload = Upload.first
    upload.update_attributes approved_record: true
    priv.images << upload.image
    pub.images << upload.image
    collab.images << upload.image

    login_as 'superadmin'

    patch upload_path(upload.id, locale: 'en'), params: {
      upload: {approved_record: false}
    }
    assert_redirected_to edit_upload_path(upload)
    assert_match /successfully updated/, flash[:notice]

    # the image should only be kept in the private collection
    # see https://redmine.prometheus-srv.uni-koeln.de/issues/796#note-36
    assert_includes priv.reload.images, upload.image
    assert_not_includes pub.reload.images, upload.image
    assert_not_includes collab.reload.images, upload.image
  end

  test "approving an upload doesn't remove it from private collections" do
    priv = Collection.find_by! title: "John's private collection"

    # see https://redmine.prometheus-srv.uni-koeln.de/issues/1087#note-12
    priv.update_column :public_access, ''

    upload = Upload.first
    upload.update_attributes approved_record: false
    priv.images << upload.image

    login_as 'superadmin'
    patch upload_path(upload.id, locale: 'en'), params: {
      upload: {approved_record: true}
    }

    assert_redirected_to edit_upload_path(upload)
    assert_match /successfully updated/, flash[:notice]
    assert_includes priv.reload.images, upload.image
  end
end
