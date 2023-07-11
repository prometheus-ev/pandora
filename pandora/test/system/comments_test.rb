require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  test 'create, update, delete, answer on an image' do
    TestSource.index

    login_as 'jdoe'

    pid = pid_for(1)
    visit "/en/image/#{pid}"

    # some of this is really slow
    using_wait_time 10 do
      open_section 'comments'

      # create
      within '#comments-section' do
        click_on 'Leave a comment'
        fill_in 'Your comment', with: 'this is nice'
        submit
      end
      assert_text 'successfully saved'

      # update
      within '#comments-section' do
        assert_text 'John Doe (You)'
        assert_text 'this is nice'

        # verify the link to the new comment
        link = find("a[title='Link to this comment']")
        assert_match /#comment\-[0-9]+$/, link[:href]

        click_on 'Edit'
        fill_in 'Edit comment', with: 'this is really nice'
        submit
      end
      assert_text 'successfully edited'

      # delete
      within '#comments-section' do
        assert_text 'this is really nice'

        click_on 'Edit'
        accept_confirm do
          click_on 'Delete this comment'
        end
      end
      assert_text 'successfully deleted'

      # answer
      within '#comments-section' do
        assert_text 'This comment has been deleted'

        click_on 'Leave a reply to this comment'
        fill_in 'Your reply', with: 'exactly!'
        submit
      end
      assert_text 'successfully saved'
      assert_css '.comment .comment p', text: 'exactly!'
    end
  end

  test 'on collection' do
    login_as 'mrossi'

    click_on 'Collection'
    click_submenu 'Public'
    click_on "John's public collection"

    using_wait_time 10 do
      open_section 'comments'
      assert_no_text 'There were problems with the following fields'

      # create
      within '#comments-section' do
        click_on 'Leave a comment'
        fill_in 'Your comment', with: 'this is nice'
        submit
      end
      assert_text 'successfully saved'

      # update
      within '#comments-section' do
        assert_text 'Mario Rossi (You)'
        assert_text 'this is nice'

        # verify the link to the new comment
        link = find("a[title='Link to this comment']")
        assert_match /#comment\-[0-9]+$/, link[:href]

        click_on 'Edit'
        fill_in 'Edit comment', with: 'this is really nice'
        submit
      end
      assert_text 'successfully edited'

      # delete
      within '#comments-section' do
        assert_text 'this is really nice'

        click_on 'Edit'
        accept_confirm do
          click_on 'Delete this comment'
        end
      end
      assert_text 'successfully deleted'

      # answer
      within '#comments-section' do
        assert_text 'This comment has been deleted'

        click_on 'Leave a reply to this comment'
        fill_in 'Your reply', with: 'exactly!'
        submit
      end
      assert_text 'successfully saved'
      assert_css '.comment .comment p', text: 'exactly!'
    end
  end

  test 'on another collection' do
    login_as 'mrossi'

    click_on 'Collection'
    click_submenu 'Public'
    click_on "John's public collection"

    using_wait_time 10 do
      open_section 'comments'

      # create
      within '#comments-section' do
        click_on 'Leave a comment'
        fill_in 'Your comment', with: 'this is nice'
        submit
      end
      assert_text 'successfully saved'

      # update
      within '#comments-section' do
        assert_text 'Mario Rossi (You)'
        assert_text 'this is nice'

        # verify the link to the new comment
        link = find("a[title='Link to this comment']")
        assert_match /#comment\-[0-9]+$/, link[:href]

        click_on 'Edit'
        fill_in 'Edit comment', with: 'this is really nice'
        submit
      end
      assert_text 'successfully edited'

      # delete
      within '#comments-section' do
        assert_text 'this is really nice'

        click_on 'Edit'
        accept_confirm do
          click_on 'Delete this comment'
        end
      end
      assert_text 'successfully deleted'

      # answer
      within '#comments-section' do
        assert_text 'This comment has been deleted'

        click_on 'Leave a reply to this comment'
        fill_in 'Your reply', with: 'exactly!'
        submit
      end
      assert_text 'successfully saved'
      assert_css '.comment .comment p', text: 'exactly!'
    end
  end

  test 'on an upload' do
    # we approve the upload so we can test indexing
    Upload.last.update approved_record: true

    login_as 'jdoe'

    click_on 'My Uploads'
    find("[title='Jean-Baptiste Dupont: A upload, Köln']").click

    # create
    within '#comments-section' do
      click_on 'Leave a comment'
      fill_in 'Your comment', with: 'this is nice'
      submit
    end
    assert_text 'successfully saved'

    doc = Upload.last.super_image.elastic_record['_source']
    assert_equal 'this is nice', doc['user_comments']

    # update
    within '#comments-section' do
      assert_text 'John Doe (You)'
      assert_text 'this is nice'

      # verify the link to the new comment
      link = find("a[title='Link to this comment']")
      assert_match /#comment\-[0-9]+$/, link[:href]

      click_on 'Edit'
      fill_in 'Edit comment', with: 'this is really nice'
      submit
    end
    assert_text 'successfully edited'

    doc = Upload.last.super_image.elastic_record['_source']
    assert_equal 'this is really nice', doc['user_comments']

    # delete
    within '#comments-section' do
      assert_text 'this is really nice'

      click_on 'Edit'
      accept_confirm do
        click_on 'Delete this comment'
      end
    end
    assert_text 'successfully deleted'

    doc = Upload.last.super_image.elastic_record['_source']
    assert_equal '', doc['user_comments']

    # answer
    within '#comments-section' do
      assert_text 'This comment has been deleted'

      click_on 'Leave a reply to this comment'
      fill_in 'Your reply', with: 'exactly!'
      submit
    end
    assert_text 'successfully saved'
    assert_css '.comment .comment p', text: 'exactly!'

    doc = Upload.last.super_image.elastic_record['_source']
    assert_equal 'exactly!', doc['user_comments']
  end
end
