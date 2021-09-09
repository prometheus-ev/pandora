class Pandora::ConferenceSignup
  include ActiveModel::Model

  TITLE = '4D – Dimensionen – Disziplinen – Digitalität – Daten'
  DATE = '01.10.2021 bis 02.10.2021'

  attr_accessor :person_title
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :institution
  attr_accessor :street
  attr_accessor :postal_code
  attr_accessor :city
  attr_accessor :country

  attr_accessor :presence

  attr_accessor :empfang
  attr_accessor :feier
  attr_accessor :abendessen

  attr_accessor :note

  validate do |cs|
    [:first_name, :last_name, :email, :street, :postal_code, :city, :country].each do |a|
      if cs.send(a).blank?
        cs.errors.add :base, "Your #{a.to_s.gsub('_', ' ')} was empty...".t
      end
    end

    if cs.email && !Util::Email.valid?(cs.email)
      cs.errors.add :base, 'Your e-mail address is invalid'.t
    end
  end
end
