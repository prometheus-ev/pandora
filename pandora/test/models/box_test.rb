require 'test_helper'

class BoxTest < ActiveSupport::TestCase

  # test 'create image box by params' do
  #   account = Account.find_by! login: 'jdoe'
  #   params = ActionController::Parameters.new({
  #     box: {
  #       action: "show",
  #       controller: "image",
  #       id: "daumier-ce6009aa5fbf9859b50d9ecbad698d50cbdf1ac9"
  #     },
  #     controller: "box",
  #     action: "create",
  #     locale: "en"
  #   })
    
  #   box = Box.from_params(params, account.boxes)
  #   assert_instance_of ImageBox, box
  #   # assert_equal("images", box.params["controller"])

  #   # Box.connection.execute("Update boxes set params = REPLACE(params, 
  #   #   'controller: images', 'controller: image') where id = #{box.id}")

  #   box = Box.find(box.id)
  #   assert_instance_of ImageBox, box
  #   # assert_equal("images", box.params["controller"])
  # end

  # test 'create collection box by params' do
  #   account = Account.find_by! login: 'jdoe'
  #   collection = account.collections.first
  #   params = ActionController::Parameters.new({
  #     box: {
  #       action: "show",
  #       controller: "collection",
  #       id: collection.id
  #     },
  #     controller: "box",
  #     action: "create",
  #     locale: "en"
  #   })
    
  #   box = Box.from_params(params, account.boxes)
  #   assert_instance_of CollectionBox, box
  #   # assert_equal("images", box.params["controller"])

  #   # Box.connection.execute("Update boxes set params = REPLACE(params, 
  #   #   'controller: images', 'controller: image') where id = #{box.id}")

  #   box = Box.find(box.id)
  #   assert_instance_of CollectionBox, box
  #   # assert_equal("images", box.params["controller"])
  # end
end