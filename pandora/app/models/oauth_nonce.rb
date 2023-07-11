class OauthNonce < ApplicationRecord

  validates_presence_of   :nonce, :timestamp
  validates_uniqueness_of :nonce, scope: :timestamp, case_sensitive: true

  # Remembers a nonce and it's associated timestamp. It returns false if it has
  # already been used.
  def self.remember(nonce, timestamp)
    oauth_nonce = create(:nonce => nonce, :timestamp => timestamp)
    oauth_nonce.new_record? ? false : oauth_nonce
  end

end
