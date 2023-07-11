# needed for user database creation
Keyword.create!(
  title: 'upload',
  title_de: 'Upload'
)
Keyword.create!(
  title: 'index',
  title_de: 'Index'
)
Keyword.create!(
  title: 'institutional upload',
  title_de: 'institutioneller Upload'
)

prometheus = Institution.create!(
  name: 'prometheus',
  city: 'Köln',
  title: 'prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre',
  country: 'Deutschland',
  # TODO: find out what this is and create one
  # contact_id: ???
  description: 'prometheus ist ein verteiltes Bildarchiv, das Bildmaterial aus den Bereichen Kunst- und Kulturgeschichte, Archäologie sowie Kulturgüterschutz zu Forschungs- und Lehrzwecken zur Verfügung stellt.',
  postalcode: '50931',
  homepage: 'http://www.prometheus-bildarchiv.de',
  addressline: 'An St. Laurentius 4',
  email: 'info@prometheus-bildarchiv.de',
  issuer: 'hbz'
)

superadmins = Role.create!(title: 'superadmin')
admins = Role.create!(title: 'admin')
Role.create!(title: 'useradmin')
Role.create!(title: 'webadmin')
users = Role.create!(title: 'user')
Role.create!(title: 'dbuser')
Role.create!(title: 'visitor')
Role.create!(title: 'ipuser')
Role.create!(title: 'dbadmin')
Role.create!(title: 'subscriber')

LicenseType.create!(title: 'large', amount: "1890")
LicenseType.create!(title: 'school', amount: "250")
LicenseType.create!(title: 'consortium', amount: "0")
LicenseType.create!(title: 'fh_campus', amount: "2100")
LicenseType.create!(title: 'single', amount: "30")
LicenseType.create!(title: 'fh_small', amount: "262")
LicenseType.create!(title: 'campus', amount: "4200")
LicenseType.create!(title: 'fh_medium', amount: "525")
LicenseType.create!(title: 'small', amount: "525")
LicenseType.create!(title: 'fh_large', amount: "945")
LicenseType.create!(title: 'medium', amount: "1050")
LicenseType.create!(title: 'library', amount: "250")
LicenseType.create!(title: 'school_large', amount: "400")

Account.create!(
  login: 'superadmin',
  password: 'superadmin',
  password_confirmation: 'superadmin',
  email: 'informatik@prometheus-bildarchiv.de',
  firstname: 'prometheus',
  lastname: 'SUPERADMIN',
  newsletter: false,
  institution: prometheus,
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  # REWRITE: test the negative case
  email_verified_at: Time.now,
  roles: [superadmins, users],
  research_interest: 'n.a.',
  account_settings_attributes: {
    start_page: 'administration'
  }
)
Account.create!(
  login: 'prometheus',
  password: 'prometheus',
  password_confirmation: 'prometheus',
  email: 'info@prometheus-bildarchiv.de',
  firstname: 'prometheus',
  lastname: 'Bildarchiv',
  newsletter: false,
  institution: prometheus,
  status: 'activated',
  accepted_terms_of_use_at: Time.now,
  accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
  email_verified_at: Time.now,
  roles: [admins, users],
  research_interest: 'n.a.'
)

Source.create!(
  title: 'User Uploads',
  name: 'uploads',
  kind: 'User upload',
  type: 'user_upload',
  institution: prometheus,
  record_count: 0
)

brain_busters = [
  ["en", "What is two plus two?", "4"],
  ["de", "Was ist zwei plus zwei?", "4"],
  ["en", "What is the number before twelve?", "11"],
  ["de", "Wie lautet die Zahl vor zwölf?", "11"],
  ["en", "Five times two is what?", "10"],
  ["de", "Fünf mal zwei ist was?", "10"],
  ["en", "Insert the next number in this sequence: 10, 11, 12, 13, 14, ...", "15"],
  ["de", "Nennen Sie die nächste Zahl in der Folge: 10, 11, 12, 13, 14, ...", "15"],
  ["en", "What is five times five?", "25"],
  ["de", "Was ist fünf mal fünf?", "25"],
  ["en", "Ten divided by two is what?", "5"],
  ["de", "Zehn geteilt durch zwei ist was?", "5"],
  ["en", "What day comes after Monday?", "tuesday"],
  ["de", "Welcher Tag kommt nach Montag?", "dienstag"],
  ["en", "What is the last month of the year?", "december"],
  ["de", "Welches ist der letzte Monat des Jahres?", "dezember"],
  ["en", "How many minutes are in an hour?", "60"],
  ["de", "Wie viele Minuten hat eine Stunde?", "60"],
  ["en", "What is five minus two?", "3"],
  ["de", "Was ist fünf minus zwei?", "3"],
  ["en", "What is the opposite of north?", "south"],
  ["de", "Was ist das Gegenteil von Norden?", "süden"],
  ["en", "Insert the next number in this sequence: 10, 9, 8, 7, ...", "6"],
  ["de", "Nennen Sie die nächste Zahl in der Folge: 10, 9, 8, 7, ...", "6"],
  ["en", "What is 4 times four?", "16"],
  ["de", "Was ist 4 mal vier?", "16"],
  ["en", "What number comes after 20?", "21"],
  ["de", "Welche Zahl kommt nach 20?", "21"],
  ["en", "What month comes before July?", "june"],
  ["de", "Welcher Monat kommt vor Juli?", "juni"],
  ["en", "What is fifteen divided by three?", "5"],
  ["de", "Was ist fünfzehn geteilt durch drei?", "5"],
  ["en", "What is 14 minus 4?", "10"],
  ["de", "Was ist 14 minus 4?", "10"],
  ["en", "What comes next? Monday, Tuesday, Wednesday, ...", "thursday"],
  ["de", "Was kommt als nächstes? Montag, Dienstag, Mittwoch, ...", "donnerstag"],
  ["en", "How many sides does a triangle have?", "3"],
  ["de", "Wie viele Seiten hat ein Dreieck?", "3"],
  ["en", "How many days are in a week?", "7"],
  ["de", "Wie viele Tage hat eine Woche?", "7"],
  ["en", "Two weeks makes how many days?", "14"],
  ["de", "Zwei Wochen sind wie viele Tage?", "14"],
  ["en", "One meter is how many centimeters?", "100"],
  ["de", "Ein Meter hat wie viele Zentimeter?", "100"],
  ["en", "How many hours are in a day?", "24"],
  ["de", "Wie viele Stunden hat ein Tag?", "24"],
  ["en", "What is the opposite of dark?", "bright"],
  ["de", "Was ist das Gegenteil von dunkel?", "hell"],
  ["en", "What is the opposite of east?", "west"],
  ["de", "Was ist das Gegenteil von Osten?", "westen"],
  ["en", "What is the opposite of left?", "right"],
  ["de", "Was ist das Gegenteil von links?", "rechts"],
  ["en", "How many sides does a square have?", "4"],
  ["de", "Wie viele Seiten hat ein Quadrat?", "4"],
  ["en", "What is the second letter of the alphabet?", "b"],
  ["de", "Wie lautet der zweite Buchstabe im Alphabet?", "b"],
  ["en", "The third letter of the alphabet is what?", "c"],
  ["de", "Der dritte Buchstabe im Alphabet lautet wie?", "c"]
]

brain_busters.each do |r|
  BrainBuster.create!(lang: r[0], question: r[1], answer: r[2])
end
