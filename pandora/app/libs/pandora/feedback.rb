class Pandora::Feedback
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :email
  attr_accessor :text

  validate do |f|
    [:name, :email].each do |a|
      if f.send(a).blank?
        f.errors.add :base, "Your #{a} was empty...".t
      end
    end

    if f.text.blank?
      f.errors.add :base, 'Your message was empty...'
    end

    if f.email && !Util::Email.valid?(f.email)
      f.errors.add :base, 'Your e-mail address is invalid'.t
    end
  end
end