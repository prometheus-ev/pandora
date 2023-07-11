require "application_system_test_case"

class SidebarTest < ApplicationSystemTestCase
  test 'add a collection to the sidebar and paginate' do
    login_as 'mrossi'

    ['galette', 'john', 'last_supper', 'leonardo', 'rembrandt', 'woman', 'skull'].each do |f|
      u = create_upload f
      u.update_column :approved_record, true
    end

    # it shouldn't be possible to add unapproved uploads to a public collection!
    c = Collection.find_by!(title: "John's collaboration collection")
    Upload.all.each do |upload|
      c.images << upload.image
    end

    create_upload 'skull'

    click_on 'Collections'
    click_submenu 'Public'
    click_on "John's collaboration collection"
    click_on 'Add collection to sidebar'

    using_wait_time 10 do
      within '#sidebar' do
        assert_text 'by John Doe'
        assert_text "John's collaborat..."

        assert_css '.thumbnail', count: 6
        find('.icon_next').click
        assert_css '.thumbnail', count: 1

        fill_in 'page', with: '1'
        find('.button_middle').click
        assert_css '.thumbnail', count: 6
      end
    end

    # test with deactivated collection owner
    c.owner.update status: 'deactivated'
    visit '/'

    within '#sidebar' do
      assert_no_text 'by N.N.'
      assert_text 'by John Doe'
      assert_text "John's collaborat..."

      within '#boxes' do
        find("#boxes div[title=Open]").click
      end
    end

    assert_no_text 'This collection is no longer available'
    assert_text "John's collaboration collection"
    assert_text 'by John Doe'
    
    # add a second collection
    click_on 'Add collection to sidebar'
    assert_css '#boxes > .sidebar_box', count: 2
  end

  test 'add (and remove) an image to the sidebar' do
    login_as 'jdoe'

    click_on 'My Uploads'
    find("[title='Store image in...']").find(:xpath, '..').click
    click_on 'Add image to sidebar'

    within '#sidebar' do
      assert_text 'Jean-Baptiste ' # ... Dupont: A Upload
      
      dismiss_confirm do
        find('div.close').click
      end
      assert_text 'Jean-Baptiste'

      accept_confirm do
        find('div.close').click
      end
      
      assert_no_text 'Jean-Baptiste'
    end
  end
  
  test 'render box with outdated params' do
    jdoe = Account.find_by! login: 'jdoe'

    image = Upload.last.image
    Box.create!(
      ref_type: 'image',
      owner_id: jdoe.id,
      image_id: image.id,
    )

    collection = Collection.find_by! title: "John's private collection"
    collection.images << image
    Box.create!(
      ref_type: 'collection',
      owner_id: jdoe.id,
      collection_id: collection.id,
    )

    login_as 'jdoe'
    visit '/en'
    assert_text 'Jean-Baptiste' # the upload's artist, visible in the sidebar
    assert_text "John's private"
  end

  # test 'reorder boxes'
  # 2021-05-02: tried to implement this test but capybara isn't there yet: the
  # element can be dragged but not to a specific location within an element

  # test "can't view restricted box content"
end
