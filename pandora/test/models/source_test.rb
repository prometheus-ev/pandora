require 'test_helper'
require "test_sources/test_source"

class SourceTest < ActiveSupport::TestCase
  test 'record count updates when new source is indexed' do
    TestSource.index
    assert_equal 12, Source.find_by_name('test_source').record_count
  end

  test 'record count updates when existing source is indexed' do
    TestSource.index
    assert_equal 12, Source.find_by_name('test_source').record_count

    # TODO: Stub the file to index after indexing is refactored.
    FileUtils.cp 'test/fixtures/data/test_source.xml', 'test/fixtures/data/test_source.xml.backup'
    doc = Nokogiri::XML(File.open('test/fixtures/data/test_source.xml'))
    row = doc.at_css "row"
    row.add_next_sibling "<row><id>13</id></row>"
    File.write('test/fixtures/data/test_source.xml', doc.to_xml)

    TestSource.index
    assert_equal 13, Source.find_by_name('test_source').record_count
  ensure
    if File.exist?('test/fixtures/data/test_source.xml.backup')
      FileUtils.cp 'test/fixtures/data/test_source.xml.backup', 'test/fixtures/data/test_source.xml'
      FileUtils.remove_file 'test/fixtures/data/test_source.xml.backup'
    end
  end

  test 'create keywords in current locale' do
    source = Source.new

    source.assign_attributes keyword_list: 'sun, sky'
    assert_equal 'sun', source.keywords[0].title
    assert source.keywords[0].title_de.blank?
    assert_equal 'sky', source.keywords[1].title
    assert source.keywords[1].title_de.blank?

    with_locale :de do
      source.update keyword_list: 'sonne, himmel'
      assert source.keywords[0].title.blank?
      assert_equal 'sonne', source.keywords[0].title_de
      assert source.keywords[1].title.blank?
      assert_equal 'himmel', source.keywords[1].title_de
    end
  end

  test "create_user_database doesn't validate user instance" do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.database.destroy
    jdoe.update_column :crypted_password, ""
    jdoe.reload

    # shouldn't raise ActiveRecord::RecordInvalid
    jdoe.database
  end

  test 'auto-approval' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])

    # source not auto-approving -> upload not approved
    skull = create_upload('skull')
    assert_not skull.approved_record?

    # source not auto-approving -> upload not approved
    galette = create_upload('galette', database: database)
    assert_not galette.approved_record?

    # source auto-approving -> upload not approved, because created earlier
    database.update(auto_approve_records: true)
    assert_not skull.approved_record?
    assert_not galette.approved_record?

    # source auto-approviing -> upload approved
    leonardo = create_upload('leonardo', database: database)
    assert leonardo.approved_record?
  end
end
