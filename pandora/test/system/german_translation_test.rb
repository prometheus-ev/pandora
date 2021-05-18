require "application_system_test_case"

# We have decided that we will not cover translation values in the test suite to
# facilitate development in the future. However, there are many translated views
# (path/to/file.de.html.erb) which unfortunatelly also include some logic. We
# will add tests for those cases here.

class GermanTranslationTest < ApplicationSystemTestCase
  test 'all help should be available' do
    login_as 'superadmin'
    click_on 'Deutsch'

    tests = [
      ['Registrierung', 'Ausfüllen des Registrierungsformulars'],
      ['Login-Name', 'Persönlicher Zugang'],
      ['Suche', 'Suchsyntax'],
      ['Suchsyntax', 'Phrasensuche'],
      ['Ergebnisliste', 'Ergebnisse'],
      ['Bildrecht und Publikation', 'Informationen zum Bildrecht'],
      ['Bildsammlung', 'Anlegen von Bildsammlungen'],
      ['Meine Uploads', 'Hochladen eigener Bilder'],
      ['Favoritenleiste', 'Die Favoritenleiste'],
      ['Verwaltung', 'Verwaltung für den persönlichen Zugang'],
      ['Profil', 'Ihr persönliches Profil']
    ]

    tests.each do |t|
      within('#footer'){click_on 'Hilfe'}
      within '#content' do
        click_on t[0]
        assert_text t[1]
      end
    end
  end

  test 'signup' do
    visit '/'
    click_on 'Deutsch'
    click_on 'Registrieren'
    assert_text 'Woche kostenlos testen'
  end
end
