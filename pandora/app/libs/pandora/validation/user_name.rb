class Pandora::Validation::UserName < ActiveModel::Validator
  def validate(record)
    # We accept all values currently in the database. The user can still change
    # other attributes for is Account but when he changes the login, the new
    # value has to match our guidelines
    return unless record.login_changed?

    # we allow this so that newsletter subscriptions still works
    return if record.login == "N:#{record.email}"

    unless record.login.match(/^[a-zA-Z][a-zA-Z0-9_.]+[a-zA-Z0-9_]$/)
      record.errors.add :login, :invalid_user_name
    end

    unless record.login.length >= 3
      record.errors.add :login, :too_short
    end

    unless record.login.length <= 30
      record.errors.add :login, :too_long
    end

    stop_words = ['active', 'pending', 'expired', 'guest', 'email']
    if stop_words.include?(record.login)
      record.errors.add :login, :invalid
    end
  end
end
