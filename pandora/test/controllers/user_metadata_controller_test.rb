require 'test_helper'

class UserMetadataControllerTest < ActionDispatch::IntegrationTest
  setup do
    require_test_sources
  end

  teardown do
    Indexing::Index.delete("test*")
  end

  test "denies access unless logged in" do
    TestSource.index
    pid = pid_for(1)

    patch "/api/json/user_metadata/#{pid}/artist", params: {
      value: 'Leonardo'
    }

    assert_response :unauthorized
  end

  test "creates value" do
    TestSource.index
    pid = pid_for(1)

    jdoe = Account.find_by!(login: 'jdoe')
    admin = Account.find_by!(login: 'prometheus')
    login_as 'jdoe'

    patch "/api/json/user_metadata/#{pid}/artist", params: {
      value: 'Leonardo'
    }
    assert_response :success
    values = UserMetadata.apply_updates_to([], pid, 'artist')
    assert_equal ['Leonardo'], values

    # do it again
    patch "/api/json/user_metadata/#{pid}/artist", params: {
      value: 'Verrocchio'
    }

    values = UserMetadata.apply_updates_to([], pid, 'artist')
    assert_equal ['Verrocchio'], values
  end

  # test 'creates a multi value' do
  #   login_as 'jdoe'

  #   patch '/api/json/user_metadata/pid-1234/artist/2', params: {
  #     value: 'Leonardo'
  #   }
  #   assert_response :success

  #   values = UserMetadata.apply_updates_to([], 'pid-1234', 'artist')
  #   assert_equal [nil, nil, 'Leonardo'], values
  # end

  test 'overrides existing value' do
    TestSource.index
    pid = pid_for(1)

    login_as 'jdoe'
    jdoe = Account.find_by!(login: 'jdoe')

    UserMetadata.create!(
      pid: pid,
      field: 'artist',
      value: 'Leonardo',
      account: jdoe
    )
    values = UserMetadata.apply_updates_to([], pid, 'artist')
    assert_equal ['Leonardo'], values

    patch "/api/json/user_metadata/#{pid}/artist", params: {
      value: 'Leonardo da Vinci'
    }
    assert_response :success

    values = UserMetadata.apply_updates_to([], pid, 'artist')
    assert_equal ['Leonardo da Vinci'], values
  end

  test 'nested_artist values (unmodified data)' do
    TestSourceNestedFields.index
    si = Pandora::SuperImage.from_upstream_id('test_source_nested_fields', "1")
    admin = Account.find_by!(login: 'prometheus')
    values = [
      {"name" => "Andrea del Verrocchio", "dating" => "1435-1488", "wikidata" => "Q183458"},
      {"name" => "Leonardo da Vinci", "dating" => "1452-1519", "wikidata" => "Q762"},
      {"name" => "Raphael"}
    ]
    assert_equal values, si.user_values_for('artist_nested', account: admin)
  end

  test 'nested_artist values (change a single wikidata id)' do
    TestSourceNestedFields.index
    admin = Account.find_by!(login: 'prometheus')
    si = Pandora::SuperImage.from_upstream_id('test_source_nested_fields', "1")

    login_as 'jdoe'

    patch "/api/json/user_metadata/#{si.pid}/artist_nested.wikidata", params: {
      value: 'Q777',
      position: 1
    }
    values = [
      {"name" => "Andrea del Verrocchio", "dating" => "1435-1488", "wikidata" => "Q183458"},
      {"name" => "Leonardo da Vinci", "dating" => "1452-1519", "wikidata" => "Q777"},
      {"name" => "Raphael"}
    ]
    assert_equal values, si.user_values_for('artist_nested', account: admin)
  end

  # test 'nested_artist values (change a wikidata id in a non-existing sub doc)' do
  #   TestSourceNestedFields.index
  #   admin = Account.find_by!(login: 'prometheus')
  #   si = Pandora::SuperImage.from_upstream_id('test_source_nested_fields', "1")

  #   login_as 'jdoe'

  #   patch "/api/json/user_metadata/#{si.pid}/artist_nested.wikidata", params: {
  #     value: 'Q888',
  #     position: 4
  #   }
  #   values = [
  #     {"name" => "Andrea del Verrocchio", "dating" => "1435-1488", "wikidata" => "Q183458"},
  #     {"name" => "Leonardo da Vinci", "dating" => "1452-1519", "wikidata" => "Q762"},
  #     {"name" => "Raphael"},
  #     nil,
  #     nil,
  #     {"wikidata" => "Q888"}
  #   ]
  #   assert_equal values, si.user_values_for('artist_nested', account: admin)
  # end

  test 'nested_artist values (remove a wikidata id)' do
    TestSourceNestedFields.index
    admin = Account.find_by!(login: 'prometheus')
    si = Pandora::SuperImage.from_upstream_id('test_source_nested_fields', "1")

    login_as 'jdoe'

    patch "/api/json/user_metadata/#{si.pid}/artist_nested.wikidata", params: {
      value: nil,
      position: 1
    }
    assert_response :success

    values = [
      {"name" => "Andrea del Verrocchio", "dating" => "1435-1488", "wikidata" => "Q183458"},
      {"name" => "Leonardo da Vinci", "dating" => "1452-1519", "wikidata" => nil},
      {"name" => "Raphael"}
    ]
    assert_equal values, si.user_values_for('artist_nested', account: admin)
  end

  test 'refuses to store values for invalid fields' do
    TestSource.index
    pid = pid_for(1)

    login_as 'jdoe'

    patch "/api/json/user_metadata/#{pid}/artist", params: {value: 'Someone'}
    assert_response :success

    patch "/api/json/user_metadata/#{pid}/shoe", params: {value: 'Someone'}
    assert_response :unprocessable_entity

    patch "/api/json/user_metadata/#{pid}/dimension", params: {value: 'Someone'}
    assert_response :unprocessable_entity

    assert_raises ActionController::RoutingError do
      patch "/api/json/user_metadata/#{pid}", params: {value: 'Someone'}
    end

    assert_raises ActionController::RoutingError do
      patch "/api/json/user_metadata/#{pid}", params: {field: nil, value: 'Someone'}
    end

    assert_raises ActionController::RoutingError do
      patch "/api/json/user_metadata/#{pid}", params: {field: '', value: 'Someone'}
    end
  end

  # test 'deal with invalid field names (security)'
end
