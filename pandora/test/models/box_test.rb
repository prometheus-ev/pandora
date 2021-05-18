require 'test_helper'

class BoxTest < ActiveSupport::TestCase

  # due to the presence of old controller name "image" set by App
  # can be removed when #788 fixed
  test 'overwrite of image box controller param' do
    account = Account.find_by! login: 'jdoe'
    params = ActionController::Parameters.new({
      box: {
        action: "show",
        controller: "image",
        id: "daumier-ce6009aa5fbf9859b50d9ecbad698d50cbdf1ac9"
        },
      controller: "box",
      action: "create",
      locale: "en"
    })
    
    box = Box.from_params(params, account.boxes)
    assert_equal("images", box.params["controller"])

    Box.connection.execute("Update boxes set params = REPLACE(params, 
      'controller: images', 'controller: image') where id = #{box.id}")

    box = Box.find(box.id)
    assert_equal("images", box.params["controller"])
  end
end