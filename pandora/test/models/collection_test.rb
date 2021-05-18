require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  test 'find allowed' do
    assert_empty Collection.allowed(nil)

    mrossi = Account.find_by!(login: 'mrossi')
    pub = Collection.find_by!(title: "John's public collection")
    priv = Collection.find_by!(title: "John's private collection")
    colab = Collection.find_by!(title: "John's collaboration collection")

    assert_same_elements [
      "John Expired's public collection",
      "John's public collection",
      "John's collaboration collection"
    ], Collection.allowed(mrossi).pluck(:title)

    assert_same_elements [
      "John's collaboration collection"
    ], Collection.allowed(mrossi, :write).pluck(:title)

    priv.viewers << mrossi

    assert_same_elements [
      "John Expired's public collection",
      "John's public collection",
      "John's private collection",
      "John's collaboration collection"
    ], Collection.allowed(mrossi).pluck(:title)

    assert_same_elements [
      "John's collaboration collection"
    ], Collection.allowed(mrossi, :write).pluck(:title)

    priv.collaborators << mrossi

    assert_same_elements [
      "John Expired's public collection",
      "John's public collection",
      "John's private collection",
      "John's collaboration collection"
    ], Collection.allowed(mrossi).pluck(:title)

    assert_same_elements [
      "John's collaboration collection",
      "John's private collection",
    ], Collection.allowed(mrossi, :write).pluck(:title)

    priv.update viewers: []

    assert_same_elements [
      "John Expired's public collection",
      "John's public collection",
      "John's private collection",
      "John's collaboration collection"
    ], Collection.allowed(mrossi).pluck(:title)

    assert_same_elements [
      "John's collaboration collection",
      "John's private collection",
    ], Collection.allowed(mrossi, :write).pluck(:title)
  end

  test 'search' do
    assert_raises Pandora::Exception do
      Collection.search('firstname', 'Klaus')
    end

    results = Collection.search('title', 'private').pluck(:title)
    assert_same_elements ["John's private collection"], results

    results = Collection.search('description', 'only John can change').pluck(:title)
    assert_same_elements ["John's public collection"], results

    results = Collection.search('keywords', '1988').pluck(:title)
    assert_same_elements ["John's private collection"], results

    jdoe = Account.find_by! login: 'jdoe'
    results = Collection.search('owner', 'jdoe').pluck(:title)
    assert_same_elements [
      "John's private collection",
      "John's public collection",
      "John's collaboration collection"
    ], results

    results = Collection.search('owner', 'john doe').pluck(:title)
    assert_same_elements [
      "John's private collection",
      "John's public collection",
      "John's collaboration collection"
    ], results
  end

  # test 'active / expired' do
  #   results = Collection.active.pluck(:title)
  #   assert_same_elements [
  #     "John's private collection",
  #     "John's public collection",
  #     "John's collaboration collection"
  #   ], results

  #   results = Collection.expired.pluck(:title)
  #   assert_same_elements ["John Expired's public collection",], results    
  # end

  test 'insertion order' do
    priv = Collection.find_by!(title: "John's private collection")
    pids = [
      'daumier-185d385f0fa853579f9894544a75566e95d45fd0',
      'daumier-cf03d626ef05e83c0b610b864a95f256dea8de2a',
      'daumier-7efac9058a019e103e61d8ba2d518db2837ae206'
    ]

    # We add the images to the collection waiting for an hour in between,
    # otherwise everything happens too fast for MySQL datetime column
    # granularity
    pids.each_with_index do |pid, i|
      travel_to (i + 5).hours.from_now do
        si = Pandora::SuperImage.find(pid)
        priv.images << si.image
      end
    end

    # here, we just check that the order is retrievable via the timestamp
    insertion_order = priv.images.order('collections_images.created_at')
    assert_equal pids, insertion_order.map(&:pid)
  end

  test 'counts for' do
    priv = Collection.find_by!(title: "John's private collection")
    pub = Collection.find_by!(title: "John's public collection")
    collab = Collection.find_by!(title: "John's collaboration collection")

    #collab.update_attributes meta_image: true

    pids = [
      'daumier-185d385f0fa853579f9894544a75566e95d45fd0',
      'daumier-cf03d626ef05e83c0b610b864a95f256dea8de2a',
      'daumier-7efac9058a019e103e61d8ba2d518db2837ae206'
    ]

    # We add the images to the collection waiting for an hour in between,
    # otherwise everything happens too fast for MySQL datetime column
    # granularity
    pids.each do |pid|
      si = Pandora::SuperImage.find(pid)
      priv.images << si.image
      pub.images << si.image
      collab.images << si.image
    end

    mrossi = Account.find_by! login: 'mrossi'
    jdoe = Account.find_by! login: 'jdoe'

    priv.viewers << mrossi

    jdoe_counts = Collection.counts_for(pids, jdoe)
    mrossi_counts = Collection.counts_for(pids, mrossi)

    values = {'own' => 3, 'shared' => 0, 'public' => 2}
    assert_equal values, jdoe_counts[pids[0]]

    values = {'own' => 0, 'shared' => 1, 'public' => 2}
    assert_equal values, mrossi_counts[pids[0]]
  end
end
