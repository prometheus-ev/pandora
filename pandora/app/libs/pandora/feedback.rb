class Pandora::Feedback
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :code
  attr_accessor :send_by_email
  attr_accessor :email
  attr_accessor :message

  validate do |f|
    if f.message.blank?
      f.errors.add :base, 'Your message was empty...'
    end

    if f.email && !f.email.empty? && !Util::Email.valid?(f.email)
      f.errors.add :base, 'Your e-mail address is invalid'.t
    end
  end
end
