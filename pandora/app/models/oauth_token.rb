class OauthToken < ApplicationRecord

  belongs_to :client_application
  belongs_to :user, :class_name => 'Account', optional: true

  validates_uniqueness_of :token, case_sensitive: true
  validates_presence_of :client_application, :token, :secret

  before_validation :generate_keys, on: :create

  def invalidated?
    invalidated_at
  end

  def invalidate!
    update_attribute(:invalidated_at, Time.now.utc)
  end

  def authorized?
    authorized_at && !invalidated?
  end

  def self.authorized
    where('invalidated_at IS NULL').
      where('authorized_at IS NOT NULL').
      order(authorized_at: 'DESC')
  end

  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end


  protected

    def generate_keys
      self.token, self.secret = generate_oauth_key, generate_oauth_key
    end

end
