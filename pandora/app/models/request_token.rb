class RequestToken < OauthToken
  attr_accessor :provided_oauth_verifier

  def authorize!(user)
    authorized? ? false : update(
      :user => user,
      :authorized_at => Time.now.utc,
      :verifier => generate_oauth_key(20)
    )
  end

  def exchange!
    !authorized? || verifier != provided_oauth_verifier ? false : RequestToken.transaction do
      access_token = AccessToken.create(:user => user, :client_application => client_application)
      invalidate!
      access_token
    end
  end

  def to_query
    "#{super}&oauth_callback_confirmed=true"
  end

  def oob?
    callback_url == 'oob'
  end

  def redirect_url
    redirect_url = oob? ? client_application.callback_url : callback_url

    unless client_application.oob? || redirect_url.blank?
      sep = redirect_url.include?('?') ? '&' : '?'
      "#{redirect_url}#{sep}oauth_token=#{token}&oauth_verifier=#{verifier}"
    end
  end
end
