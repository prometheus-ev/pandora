class RateLimit < ApplicationRecord
  LIMIT = 2000
  INTERVAL = 1.hour
  FORMAT = '%Y-%m-%dT%H'

  def self.for(request, user)
    find_or_create_by(
      key: key_for(request, user),
      timestamp: timestamp
    )
  end

  def self.get(request, user)
    self.for(request, user).tap(&:inc!)
  end

  def self.key_for(request, user = nil)
    user ? user.id : request.remote_ip
  end

  def self.timestamp(time = Time.now)
    time.utc.strftime(FORMAT)
  end

  def self.time(timestamp)
    DateTime.strptime(timestamp, FORMAT).to_time
  end

  def inc!
    self.class.transaction{increment!(:count)}
  end

  def limit
    if override = ENV['PM_API_RATE_LIMIT']
      ENV['PM_API_RATE_LIMIT'].to_i
    else
      LIMIT
    end
  end

  def exceeded?
    count > limit
  end

  def remaining
    exceeded? ? 0 : limit - count
  end

  def time
    self.class.time(timestamp)
  end

  def reset
    INTERVAL.since(time).to_i
  end

  def retry_after
    reset - Time.now.utc.to_i
  end

  def headers
    return {
      'X-RateLimit-Limit' => limit,
      'X-RateLimit-Remaining' => remaining,
      'X-RateLimit-Reset' => reset,
      'Retry-After' => retry_after
    }
  end

  def info
    return {
      'limit' => limit,
      'remaining' => remaining,
      'reset' => reset,
      'retry_after' => retry_after
    }
  end
end
