require 'test_helper'

class StoreImagesTest < ActionDispatch::IntegrationTest
  if production_sources_available?
    test 'should display flash notice for images stored in collection' do
      jdoes_private_collection = Collection.find_by(:title => "John's private collection")
      login_as 'jdoe'

      get '/en/searches'
      assert_response :success

      post '/en/collections/store', params: {
        "target_collection" => {"collection_id" => jdoes_private_collection.id},
        "image" => ["daumier-81155e6c094914ee5ec444248ffb86dc06fbd38a"]
      }
      assert_redirected_to '/en/searches'
      follow_redirect!

      assert_match /Image successfully stored in collection/, flash[:notice][0]
    end

    test 'should display flash info for images already in collection' do
      jdoes_private_collection = Collection.find_by(:title => "John's private collection")
      login_as 'jdoe'

      get '/en/searches'
      assert_response :success

      post '/en/collections/store', params: {
        "target_collection" => {"collection_id" => jdoes_private_collection.id},
        "image"=>["daumier-81155e6c094914ee5ec444248ffb86dc06fbd38a"]
      }
      assert_redirected_to '/en/searches'
      follow_redirect!

      post '/en/collections/store', params: {
        "target_collection" => {"collection_id" => jdoes_private_collection.id},
        "image"=>["daumier-81155e6c094914ee5ec444248ffb86dc06fbd38a"]
      }
      assert_redirected_to '/en/searches'
      follow_redirect!

      assert_match /Image is already in collection/, flash[:notice][0]
    end
  end
end
