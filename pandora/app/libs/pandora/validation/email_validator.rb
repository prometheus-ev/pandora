class Pandora::Validation::EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # Util::Email does a DNS lookup for the domain which raises an
    # exeception when umlauts are present in the domain name
    idna = Pandora.run('idn', '--no-tld', value.to_s).strip
    if idna != value.to_s
      record.errors.add(attribute, 'should not contain special characters'.t)
      return
    end

    Util::Email.valid!(value.to_s)
  rescue Util::Email::EmailError => e
    record.errors.add(attribute, e.msg)
  end
end
