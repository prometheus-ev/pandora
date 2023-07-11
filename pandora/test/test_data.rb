jdoe = Account.create!(
  login: 'jdoe',
  password: 'jdoejdoe',
  password_confirmation: 'jdoejdoe',
  email: 'jdoe@prometheus-bildarchiv.de',
  firstname: 'John',
  lastname: 'Doe',
  newsletter: false,
  institution: Institution.find_by(name: 'prometheus'),
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  # REWRITE: test the negative case
  email_verified_at: Time.now,
  roles: [Role.find_by(title: 'user')],
  research_interest: 'postdoc Uni Freiburg'
)

mrossi = Account.create!(
  login: 'mrossi',
  password: 'mrossimrossi',
  password_confirmation: 'mrossimrossi',
  email: 'mrossi@prometheus-bildarchiv.de',
  firstname: 'Mario',
  lastname: 'Rossi',
  newsletter: false,
  institution: Institution.find_by(name: 'prometheus'),
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  # REWRITE: test the negative case
  email_verified_at: Time.now,
  roles: [Role.find_by(title: 'user')],
  research_interest: 'PhD candidate Goethe-Institut'
)

jexpired = Account.create!(
  login: 'jexpired',
  password: 'jexpiredjexpired',
  password_confirmation: 'jexpiredjexpired',
  email: 'jexpired@prometheus-bildarchiv.de',
  firstname: 'John',
  lastname: 'Expired',
  newsletter: false,
  institution: Institution.find_by(name: 'prometheus'),
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  # REWRITE: test the negative case
  email_verified_at: Time.now,
  expires_at: Time.now - 30.days,
  roles: [Role.find_by(title: 'user')],
  research_interest: 'PhD drop-out Goethe-Institut'
)

nowhere = Institution.create!(
  name: 'nowhere',
  city: 'Nowhere',
  title: 'Nowhere University',
  country: 'Noland',
  description: 'for testing only',
  postalcode: '12345',
  homepage: 'https://uni-nowhere.nl',
  addressline: '1 University Drive',
  email: 'info@example.com',
  ipranges: [
    '127.0.0.0/8',
    '10.0.0.0/8'
  ].join("\n"),
  license: License.new(
    license_type: LicenseType.find_by!(title: 'library'),
    valid_from: 1.month.ago,
    paid_from: 2.months.from_now.beginning_of_quarter,
    expires_at: 1.month.from_now
  ),
  issuer: 'prometheus'
)
nowhere.update_ipuser

jdupont = Account.create!(
  login: 'jdupont',
  password: 'jdupontjdupont',
  password_confirmation: 'jdupontjdupont',
  email: 'jdupont@example.com',
  firstname: 'Jean',
  lastname: 'Dupont',
  newsletter: false,
  institution: nowhere,
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  email_verified_at: Time.now,
  roles: Role.where(title: ['user', 'useradmin']).to_a,
  research_interest: 'none - database administrator at Nowhere University'
)
nowhere.update!(admins: [jdupont])

jnadie = Account.create!(
  login: 'jnadie',
  password: 'jnadiejnadie',
  password_confirmation: 'jnadiejnadie',
  email: 'jnadie@prometheus-bildarchiv.de',
  firstname: 'Juan',
  lastname: 'Nadie',
  newsletter: false,
  institution: Institution.find_by(name: 'prometheus'),
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  email_verified_at: Time.now,
  roles: [Role.find_by(title: 'admin')],
  research_interest: 'None, just maintaining the user base'
)

Collection.create!(
  title: "John's private collection",
  description: 'only John can see it',
  owner: jdoe,
  keywords: [Keyword.new(title: 'Italy 1988', title_de: 'Italien 1988')],
)

Collection.create!(
  title: "John's public collection",
  description: 'everybody can see it, only John can change it',
  public_access: 'read',
  owner: jdoe
)

Collection.create!(
  title: "John's collaboration collection",
  description: 'everybody can change it',
  public_access: 'write',
  owner: jdoe
)

Collection.create!(
  title: "John Expired's public collection",
  description: 'everybody can see it, even though John Expired expired',
  public_access: 'read',
  owner: jexpired
)

Source.create!(
  title: 'TEST-Source',
  name: 'test_source',
  kind: 'Museum database',
  keywords: [Keyword.new(title: 'Archaeology', title_de: 'Archäologie')],
  owner: Account.new(
    login: 'test_source_admin'
  ),
  institution: Institution.create!(
    name: 'uni_halle',
    title: 'University of Halle',
    city: 'Halle',
    country: 'Germany'
  ),
  record_count: 12,
  description: 'A test tource',
  url: 'http://nothing.nowhere.com',
  email: 'test_source@example.com',
)

Source.create!(
  title: 'TEST-Source (sorting)',
  name: 'test_source_sorting',
  kind: 'Research database',
  keywords: [Keyword.new(title: 'Art history', title_de: 'Kunstgeschichte')],
  owner: Account.new(
    login: 'test_source_sorting_admin'
  ),
  institution: Institution.create!(
    name: 'uni_ascona',
    title: 'University of Ascona',
    city: 'Ascona',
    country: 'Switzerland'
  ),
  record_count: 12,
  description: 'Something else',
  url: 'http://nothing.nowhere.com',
  email: 'test_source_sorting@example.com',
)

database = Source.create_user_database(jdoe)

upload = Upload.create!(
  database: database,
  artist: 'Jean-Baptiste Dupont',
  title: 'A upload',
  location: 'Köln',
  description: 'art',
  keywords: [Keyword.new(title: 'painting', title_de: 'Gemälde')],
  inventory_no: '12345',
  rights_reproduction: 'None, do not use!',
  rights_work: 'None, do not use!',
  file: Rack::Test::UploadedFile.new(
    "#{Rails.root}/test/fixtures/files/mona_lisa.jpg",
    'image/jpeg'
  ),
  add_to_index: true
)

ClientApplication.create!(
  name: 'Meta-Image',
  url: 'http://meta-image.de/',
  callback_url: 'oob',
  key: 'somekey',
  secret: 'somesecret'
)
