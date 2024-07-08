require 'test_helper'

Dir["./test/test_sources/*.rb"].each{|file| require file}

class ElasticTest < ActiveSupport::TestCase
  test 'create_index_and_switch_alias' do
    TestSource.index

    alias_name = 'test_source'

    new_index_name = elastic.create_index alias_name

    assert_equal 'test_source_2', new_index_name
    assert_equal 'test_source_1', elastic.index_name_from(alias_name: alias_name)

    elastic.add_alias_to(index_name: new_index_name)

    assert_equal 'test_source_2', elastic.index_name_from(alias_name: alias_name)
  end

  test 'indexes singular uploads and institutional uploads' do
    jdoe = Account.find_by!(login: "jdoe")

    # add normal upload (created as test data, but not approved)
    upload = Upload.first
    upload.update approved_record: true
    si = Pandora::SuperImage.from(upload)
    si.index_doc
    assert_equal 1, elastic.counts[si.index_name]["objects"]
    assert_equal 1, elastic.counts[si.index_name]["records"]
    doc = elastic.record(si.index_record_id)['_source']

    # update normal

    upload.image.comments.create!(author: jdoe, text: 'Also amazing!')
    upload.image.update(score: 2.5, votes: 8)
    upload.index_doc
    doc = elastic.record(si.index_record_id)['_source']
    assert_equal ['A upload'], doc['title']
    assert_equal 2, doc['rating_average']
    assert_equal 8, doc['rating_count']
    assert_equal 1, doc['comment_count']
    assert_equal 'Also amazing!', doc['user_comments']

    # add normal upload
    upload = create_upload('skull', approved_record: true)
    upload.index_doc
    si = Pandora::SuperImage.from(upload)
    doc = elastic.record(si.index_record_id)['_source']
    assert_equal ['Skull'], doc['title']

    # add institutional upload

    jdoe.roles << Role.find_by(title: 'dbadmin')
    source = institutional_upload_source([jdoe])
    upload = institutional_upload(source, 'galette', approved_record: true)
    upload.image.comments.create!(author: jdoe, text: 'Amazing!')
    upload.image.update(score: 3.5, votes: 7)
    upload.index_doc
    si = Pandora::SuperImage.from(upload)
    assert_equal 1, elastic.counts[si.index_name]["objects"]
    assert_equal 1, elastic.counts[si.index_name]["records"]
    doc = elastic.record(si.index_record_id)['_source']
    assert_equal ['Galette'], doc['title']
    assert_equal 3, doc['rating_average']
    assert_equal 7, doc['rating_count']
    assert_equal 1, doc['comment_count']
    assert_equal 'Amazing!', doc['user_comments']

    # remove normal upload

    upload = Upload.first
    upload.destroy
    upload.remove_index_doc
    si = Pandora::SuperImage.from(upload)
    db = si.index_name
    assert_equal 1, elastic.counts[db]["objects"]
    assert_equal 1, elastic.counts[db]["records"]

    # remove institutional upload

    upload = source.uploads.first
    upload.remove_index_doc
    si = Pandora::SuperImage.from(upload)
    upload.destroy
    assert_nil elastic.counts['prometheus']
  end
end
