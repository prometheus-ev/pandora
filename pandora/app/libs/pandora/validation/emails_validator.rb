class Pandora::Validation::EmailsValidator < Pandora::Validation::EmailValidator
  def validate_each(record, attribute, values)
    # expects a array value
    values.each do |v|
      next if special?(v)

      super(record, attribute, v)
    end
  end

  protected

    def special?(value)
      other = ['newsletter', 'activesinglelicenseusers', 'inactivesubscribers']
      return true if other.include?(value)

      regex = /\A#(.+)/
      return true if value.match?(regex)

      roles = Role.all.map{|r| r.title.pluralize}
      return true if roles.include?(value)

      return false
    end
end
