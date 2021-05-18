class ShortUrl < ApplicationRecord

  validates_presence_of   :url, :token
  validates_uniqueness_of :token

  before_validation :generate_token, on: :create

  TOKEN_LENGTH = 12
  TOKEN_CHARS  = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a

  MAX_TRIES = 10_000

  def self.for(app, options)
    # REWRITE: use new query interface
    # find_or_create_by_url(app.url_for(
    find_or_create_by(url: app.url_for(
      options.is_a?(Hash) ? options.merge(only_path: true) : options
    ))
  end

  def self.link_for(app, options)
    if short_url = self.for(app, options)
      app.url_for(
        controller: 'short_urls',
        action: 'redirect',
        token: short_url.token
      )
    end
  end

  def self.get(token)
    clean_email_link_params!(token)

    find_by(token: token)
  end

  def to_s
    "#{token} -> #{url}"
  end


  protected

    def generate_token
      token, i = nil, 0

      begin
        token = Array.new(TOKEN_LENGTH) { TOKEN_CHARS.sample }.join
      end while (i += 1) < MAX_TRIES && self.class.exists?(token: token)

      self.token = token
    end

end
