require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  if production_sources_available?
    test 'create, update, delete, answer on an image' do
      login_as 'jdoe'

      visit '/en/image/daumier-cf03d626ef05e83c0b610b864a95f256dea8de2a'

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

  # TODO: this actually tests commenting on a collection
  test 'upload commenting' do
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
end
