require 'test_helper'

class CsvStatsTest < ActiveSupport::TestCase
  test 'institutions are returned in alphabetical order' do
    Institution.create!(
      title: 'RWTH Aachen',
      name: 'aachen_uni',
      city: 'Aachen',
      country: 'Germany',
      license: License.new(
        license_type: LicenseType.find_by!(title: 'campus'),
        valid_from: 2.days.ago,
        expires_at: 1.year.from_now
      )
    )

    admin = Account.find_by! login: 'superadmin'
    stats = CsvStats.for(admin, {})
    csv = CsvStats.get_csv([Date.today.year, Date.today.month],
                           [Date.today.year, Date.today.month],
                           [],
                           {institution: 'aachen_uni'})

    assert_equal(['aachen_uni',
                  'nowhere',
                  'prometheus'],
                 stats.institutions)
    assert_equal([["Year_Month",
                   "Name",
                   "Title",
                   "License",
                   "Sessions",
                   "Searches",
                   "Downloads"],
                  ["#{Date.today.strftime('%Y_%m')}",
                   "aachen_uni",
                   "RWTH Aachen",
                   "campus (4200)",
                   0,
                   0,
                   0]],
                 csv)
  end
end
