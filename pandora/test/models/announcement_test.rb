require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase

  def setup
    @announcement = valid_announcement

    super
  end

  # Validation tests

  def test_should_save_valid_announcement
    assert @announcement.save, "Not saved the valid announcement"
  end

  def test_should_not_save_announcement_without_title_de
    @announcement.title_de = nil

    assert_not @announcement.save, "Saved the announcement without title_de"
  end

  def test_should_not_save_announcement_without_title_en
    @announcement.title_en = nil

    assert_not @announcement.save, "Saved the announcement without title_en"
  end

  def test_should_not_save_announcement_without_body_de
    @announcement.body_de = nil

    assert_not @announcement.save, "Saved the announcement without body_de"
  end

  def test_should_not_save_announcement_without_body_en
    @announcement.body_en = nil

    assert_not @announcement.save, "Saved the announcement without body_en"
  end

  def test_should_not_save_announcement_without_starts_at
    @announcement.starts_at = nil

    assert_not @announcement.save, "Saved the announcement without starts_at"
  end

  def test_should_not_save_announcement_without_ends_at
    @announcement.ends_at = nil

    assert_not @announcement.save, "Saved the announcement without ends_at"
  end

  def test_should_not_save_announcement_without_role
    @announcement.role = nil

    assert_not @announcement.save, "Saved the announcement without role"
  end

  def test_should_not_save_announcement_with_invalid_role
    @announcement.role = 'batman'

    assert_not @announcement.save, "Saved the announcement with invalid role"
  end

  # Scope tests

  def test_scope_current_should_only_find_current_announcements
    populate_announcements
    announcements = Announcement.current

    assert announcements.size == 2, "Found more or less than the one current announcement"
    assert announcements.last.title_en == "English title 3", "Found another than the one current announcement"
  end

  def test_scope_since_should_only_find_announcements_since_given_time
    populate_announcements
    announcements = Announcement.since(Time.now)

    assert announcements.size == 2, "Found more or less than the announcements since now"
    assert announcements.first.title_en == "English title 4" && announcements.last.title_en == "English title 5", "Found others then the announcement since now"
  end

  def test_scope_since_should_find_all_announcements_without_given_time
    populate_announcements
    announcements = Announcement.since

    assert announcements.size == 6, "Found less than the all announcements"
  end

end
