class Pandora::ConferenceSignup
  include ActiveModel::Model

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :street
  attr_accessor :postal_code
  attr_accessor :city
  attr_accessor :email
  attr_accessor :brauhaus
  attr_accessor :akdk
  attr_accessor :country
  attr_accessor :person_title
  attr_accessor :institution
  attr_accessor :note

  validate do |cs|
    [:first_name, :last_name, :street, :postal_code, :city, :email].each do |a|
      if cs.send(a).blank?
        cs.errors.add :base, "Your #{a.to_s.gsub('_', ' ')} was empty...".t
      end
    end

    if cs.email && !Util::Email.valid?(cs.email)
      cs.errors.add :base, 'Your e-mail address is invalid'.t
    end
  end
end