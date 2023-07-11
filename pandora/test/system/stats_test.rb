require "application_system_test_case"
require 'nuggets/log_parser/rails'

class StatsTest < ApplicationSystemTestCase
  test 'download prometheus csv' do
    stats_data

    # we set the nowhere license as if it had been active at the time of the
    # download
    nowhere = Institution.find_by! name: 'nowhere'
    nowhere.license.update(
      valid_from: Date.new(2019, 1, 1),
      expires_at: Date.new(2019, 12, 31)
    )

    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Stats' do
      click_on 'Institutional stats'
    end
    select 'prometheus', from: 'Issuer'
    select '2018', from: 'csv_stats_from_year'
    select 'December', from: 'csv_stats_from_month'
    select '2019', from: 'csv_stats_to_year'
    select 'February', from: 'csv_stats_to_month'
    submit 'Generate'

    assert_text 'Jahr_Monat,Name,Title,Sessions,Searches,Downloads'
    assert_text '2018_12,nowhere,Nowhere University,0,0,0'
    assert_text '2019_01,nowhere,Nowhere University,0,0,0'
    assert_text '2019_02,nowhere,Nowhere University,7,4,0'
  end

  test 'download institution csv' do
    stats_data

    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Stats' do
      click_on 'Institutional stats'
    end
    select 'prometheus', from: 'Institution'
    select '2018', from: 'csv_stats_from_year'
    select 'December', from: 'csv_stats_from_month'
    select '2019', from: 'csv_stats_to_year'
    select 'February', from: 'csv_stats_to_month'
    submit 'Generate'

    assert_text 'Jahr_Monat,Name,Title,Sessions,Searches,Downloads'
    assert_text '2018_12,prometheus,prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre,0,0,0'
    assert_text '2019_01,prometheus,prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre,0,0,0'
    assert_text '2019_02,prometheus,prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre,75,66,20'
  end

  test 'download issuer csv' do
    stats_data

    # create child (of prometheus which has issuer='hbz') and add some stats
    # data
    office = Institution.create!(
      campus: Institution.find_by(name: 'prometheus'),
      name: 'office',
      title: 'Project Office',
      city: 'Cologne',
      country: 'Germany',
      license: License.new(
        license_type: LicenseType.find_by!(title: 'library'),
        valid_from: 1.month.ago,
        paid_from: 2.months.from_now.beginning_of_quarter,
        expires_at: 1.month.from_now
      )
    )
    SumStats.create!(
      year: 2019, month: 1, day: 17,
      institution_id: office.id,
      sessions_campus: 1,
      sessions_personalized: 8,
      searches_campus: 1,
      searches_personalized: 6,
      downloads_campus: 1,
      downloads_personalized: 4,
    )
    SumStats.create!(
      year: 2019, month: 2, day: 11,
      institution_id: office.id,
      sessions_campus: 1,
      sessions_personalized: 5,
      searches_campus: 1,
      searches_personalized: 3,
      downloads_campus: 1,
      downloads_personalized: 1,
    )

    # we also include 'nowhere' to check if its only included when licensed
    # properly
    nowhere = Institution.find_by! name: 'nowhere'
    nowhere.update(
      issuer: 'hbz'
    )
    nowhere.license.update(
      valid_from: Date.new(2019, 1, 1),
      expires_at: Date.new(2019, 12, 31)
    )

    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Stats' do
      click_on 'Institutional stats'
    end
    select 'hbz', from: 'Issuer'
    select '2018', from: 'csv_stats_from_year'
    select 'December', from: 'csv_stats_from_month'
    select '2019', from: 'csv_stats_to_year'
    select 'February', from: 'csv_stats_to_month'
    submit 'Generate'

    assert_text '2018_12,nowhere,Nowhere University,0,0,0'

    title = 'prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre'
    assert_text "2018_12,prometheus,#{title},0,0,0"
    assert_text "2019_01,prometheus,#{title},9,7,5"
    assert_text "2019_02,prometheus,#{title},81,70,22"

    # remove the license and try again (since prometheus is always licensed,
    nowhere.license.destroy

    back
    submit 'Generate'

    assert_no_text 'Nowhere University'
  end

  test 'newsletter facts' do
    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update_column :newsletter, true
    subscriber = Account.subscriber_for('someone@example.com')
    subscriber.update newsletter: true, email_verified_at: Time.now

    login_as 'superadmin'
    
    visit '/en/stats/facts'
    select '2021'
    submit 'Generate'

    assert_text 'Newsletter subscribers: 2'
  end
end
