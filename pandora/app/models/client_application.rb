class Object
  alias_method :old_method, :method
end

class ClientApplication < ApplicationRecord

  include Util::Config
  include Util::ActiveCrypter

  self.controller_name = 'oauth_clients'

  has_many :tokens, :class_name => 'OauthToken'

  REQUIRED = %w[name url key secret]

  validates_presence_of   *REQUIRED
  validates_uniqueness_of :name, :key, case_sensitive: true

  # REWRITE: added end anchor
  #URL_RE = %r{\Ahttps?://(?:\w+:?\w*@)?\S+(?::\d+)?(?:/|/[\w#!:.?+=&%@!\-/])?}i
  URL_RE = %r{\Ahttps?://(?:\w+:?\w*@)?\S+(?::\d+)?(?:/|/[\w#!:.?+=&%@!\-/])?\z}i

  validates_format_of :url,          :with => URL_RE
  validates_format_of :support_url,  :with => URL_RE, :allow_blank => true
  validates_format_of :callback_url, :with => URL_RE, :allow_blank => true, :unless => :oob?

  before_validation :generate_keys, on: :create

  attr_accessor :token_callback_url

  OAUTH_SECRET = ENV['PM_OAUTH_SECRET']

  encrypts :secret, :with => [:OAUTH_SECRET, :key]

###############################################################################
  class << self
###############################################################################

    def find_token(token_key)
      # REWRITE: use new ar interface
      # token = OauthToken.find_by_token(token_key, :include => :client_application)
      token = OauthToken.includes(:client_application).find_by(token: token_key)
      token if token && token.authorized?
    end

    def verify_request(request, options = {}, &block)
      # REWRITE: we need to support trailing slashes with oauth authentication
      # which requires the request object to reflect this in request.url which
      # uses its @fullpath instance variable. We make sure the slash is (re)added:
      if request.env['REQUEST_URI'].match(/\/(\?|$)/)
        fp = request.instance_variable_get('@fullpath')
        request.instance_variable_set('@fullpath', fp.gsub(/\/?(\?|$)/, '/\1'))
      end

      request_proxy = request_proxy_for(request, options)
      return false unless supported_request?(request_proxy)

      signature = begin
        OAuth::Signature.build(request_proxy, options, &block)
      rescue OAuth::Signature::UnknownSignatureMethod => err
        logger.info "ERROR #{err}"
        return false
      end

      if OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
        signature.verify
      else
        false
      end
    end

    
    private

      def supported_request?(request, options = {})
        request_proxy = request_proxy_for(request, options)

        request_proxy.request.auth_header? &&
        request_proxy.oauth_signature_method == 'HMAC-SHA1'
      end

      def request_proxy_for(request, options = {})
        # returns +request+ if it's already a proxy
        OAuth::RequestProxy.proxy(request, options)
      end

  end

  def to_s
    name
  end

  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end

  def create_request_token
    RequestToken.create(:client_application => self, :callback_url => token_callback_url)
  end

  def oob?
    callback_url == 'oob'
  end

  def invalidate_tokens(user, at = Time.now)
    scope = OauthToken.
      where('invalidated_at IS NULL').
      where('user_id = ?', user).
      where('authorized_at < ?', at.utc)

    scope.each do |t|
      t.invalidate!
    end
  end

  def token_for(user, invalidate = 1.day.ago)
    invalidate_tokens(user, invalidate) if invalidate

    token = create_request_token
    token if token.authorize!(user)
  end

  
  protected

    # REWRITE: it seems that this is not the intended behavior. This callback
    # overwrites any values for key and secret (on create)
    # def generate_keys
    #   self.key, self.secret = generate_oauth_key, generate_oauth_key
    # end
    def generate_keys
      if self[:key].blank?
        self.key = generate_oauth_key
      end
      if self[:secret].blank?
        self.secret = generate_oauth_key
      end
    end

end
