class Pandora::UpcomingExpiry
  def initialize
    set_url_options
    @notification_count = 0
  end

  def run
    scope = Account.
      not_notified.
      email_verified.
      with_status.
      without_role('dbadmin')

    # notify guests 3 days in advance
    scope.guests.upcoming_expiry(3.days).each{|a| notify(a)}

    # notify other accounts 1 week in advance
    scope.non_guests.upcoming_expiry(1.month).each{|a| notify(a)}

    Pandora.puts "#{@notification_count} expiration notifications sent"
  end

  def notify(account)
    @notification_count += 1

    account.deliver(:expiration_notification)
    account.notified!

    Pandora.puts [
      "sent notification to '#{account.login} <#{account.email}>'", ', ',
      account.mode, ', ',
      "expires at #{account.expires_at}"
    ].join
  end


  protected

    def set_url_options
      url = URI.parse(ENV['PM_BASE_URL'])
      ApplicationMailer.default_url_options = {
        host: url.host,
        port: url.port,
        protocol: url.scheme,
      }
    end
end
