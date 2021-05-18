class OauthToken < ApplicationRecord

  belongs_to :client_application
  belongs_to :user, :class_name => 'Account', optional: true

  validates_uniqueness_of :token
  validates_presence_of :client_application, :token, :secret

  before_validation :generate_keys, on: :create

  def invalidated?
    invalidated_at
  end

  def invalidate!
    update_attribute(:invalidated_at, Time.now.utc)
  end

  def self.conditions_for_not_invalidated
    { :conditions => 'invalidated_at IS NULL' }
  end

  def authorized?
    authorized_at && !invalidated?
  end

  def self.conditions_for_authorized
    conditions_for_not_invalidated.merge_conditions('authorized_at IS NOT NULL')
  end

  def self.authorized
    # REWRITE: use new query interface
    # find(:all, conditions_for_authorized.merge(:order => 'authorized_at DESC'))
    Upgrade.conds_to_scopes(self, conditions_for_authorized.merge(:order => 'authorized_at DESC'))
  end

  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end


  protected

    def generate_keys
      self.token, self.secret = generate_oauth_key, generate_oauth_key
    end

end
