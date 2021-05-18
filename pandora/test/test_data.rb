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

nowhere = Institution.create!({
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
  license: License.new({
    license_type: LicenseType.find_by!(title: 'library'),
    valid_from: 1.month.ago,
    paid_from: 2.months.from_now.beginning_of_quarter,
    expires_at: 1.month.from_now
  }, without_protection: true),
  issuer: 'prometheus'
}, without_protection: true)
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
nowhere.update!({admins: [jdupont]}, without_protection: true)

jnadie = Account.create!({
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
}, without_protection: true)

Collection.create!({
  title: "John's private collection",
  description: 'only John can see it',
  owner: jdoe,
  keywords: [Keyword.new(title: 'Italy 1988')],
}, without_protection: true)

Collection.create!({
  title: "John's public collection",
  description: 'everybody can see it, only John can change it',
  public_access: 'read',
  owner: jdoe
}, without_protection: true)

Collection.create!({
  title: "John's collaboration collection",
  description: 'everybody can change it',
  public_access: 'write',
  owner: jdoe
}, without_protection: true)

Collection.create!({
  title: "John Expired's public collection",
  description: 'everybody can see it, even though John Expired expired',
  public_access: 'read',
  owner: jexpired
}, without_protection: true)

Source.create!({
  title: 'ROBERTIN-database',
  name: 'robertin',
  kind: 'Museum database',
  keywords: [Keyword.new(title: 'Archaeology')],
  owner: Account.new({
    login: 'robertin_admin'
  }, without_protection: true),
  institution: Institution.create!({
    name: 'robertin',
    title: 'Martin-Luther-Universität, Institut für Klassische Altertumswissenschaften',
    city: 'Halle',
    country: 'Germany'
  }, without_protection: true),
  record_count: 429,
  description: 'Robertin',
  url: 'http://robertin.altertum.uni-halle.de/',
  email: 'robertin@example.com',
}, without_protection: true)

Source.create!({
  title: 'Daumier Register',
  name: 'daumier',
  kind: 'Research database',
  keywords: [Keyword.new({title: 'Art history'}, without_protection: true)],
  owner: Account.new({
    login: 'daumier_admin'
  }, without_protection: true),
  institution: Institution.create!({
    name: 'daumier',
    title: 'Daumier Register',
    city: 'Ascona',
    country: 'Switzerland'
  }, without_protection: true),
  record_count: 6561,
  description: 'Daumier',
  url: 'http://www.daumier-register.org/login.php?startpage',
  email: 'daumier@example.com'
}, without_protection: true)

database = Source.create_user_database(jdoe)

upload = Upload.create!(
  database: database,
  artist: 'Jean-Baptiste Dupont',
  title: 'A upload',
  location: 'Köln',
  description: 'art',
  keyword_list: "painting",
  inventory_no: '12345',
  rights_reproduction: 'None, do not use!',
  rights_work: 'None, do not use!',
  file: Rack::Test::UploadedFile.new(
    "#{Rails.root}/test/fixtures/files/mona_lisa.jpg",
    'image/jpeg'
  )
)

ClientApplication.create!({
  name: 'Meta-Image',
  url: 'http://meta-image.de/',
  callback_url: 'oob',
  key: 'somekey',
  secret: 'somesecret'
}, without_protection: true)
