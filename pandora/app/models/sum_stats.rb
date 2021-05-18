class SumStats < ApplicationRecord
  def self.campus_sessions
    sum(:sessions_campus)
  end

  def self.campus_searches
    sum(:searches_campus)
  end

  def self.campus_downloads
    sum(:downloads_campus)
  end

  def self.personalized_sessions
    sum(:sessions_personalized)
  end

  def self.personalized_searches
    sum(:searches_personalized)
  end

  def self.personalized_downloads
    sum(:downloads_personalized)
  end

  def self.total_sessions
    campus_sessions + personalized_sessions
  end

  def self.total_searches
    campus_searches + personalized_searches
  end

  def self.total_downloads
    campus_downloads + personalized_downloads
  end
end
