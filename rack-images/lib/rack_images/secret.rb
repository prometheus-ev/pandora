require 'digest'

module RackImages::Secret
  TOKEN_LIFETIME = 60 * 60 # 1 hour
  
  TOKEN_LENGTH = 40
  TIMESTAMP_LENGTH = 10

  # verify a token given a request path
  # @param [String] token the token
  # @param [String] request_path the request path
  # @return [Boolean] true if token is valid, false otherwise
  def self.valid?(token, request_path)
    return false if [nil, ''].include?(token)

    timestamp = token.slice(0, TIMESTAMP_LENGTH).to_i
    
    return false if timestamp < Time.now.to_i

    key = token.slice(TIMESTAMP_LENGTH, TOKEN_LENGTH)
    return false if key != key_for(request_path, timestamp) 

    true
  end

  # generates token to be used as _asd= parameter value in urls
  # @param [String] request_path the request path
  # @param [Integer, String] timestamp the timestamp (utc seconds since 1970)
  # @return [String] token
  def self.token_for(request_path, timestamp = nil)
    timestamp ||= Time.now.to_i + TOKEN_LIFETIME

    key = key_for(request_path, timestamp)
    "#{timestamp}#{key}"
  end


  protected

    # generates a SHA1 hash for a request_path and timestamp, incorporating the
    # asd secret
    # @param [String] request_path the request path
    # @param [Integer, String] timestamp the timestamp (utc seconds since 1970)
    # @return [String] SHA1 hash
    def self.key_for(request_path, timestamp)
      Digest::SHA1.hexdigest("#{ENV['PM_ASD_SECRET']}#{request_path}#{timestamp}")
    end
end
