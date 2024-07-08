class Announcement < ApplicationRecord
  include Util::Config

  validates :title_de, presence: true
  validates :title_en, presence: true
  validates :body_de, presence: true
  validates :body_en, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :role, presence: true
  validates :role, inclusion: {in: %w(anyone users admins), message: "%{value} is not a valid role"}

  scope :current, ->{where(["starts_at < ? and ends_at > ?", Time.now, Time.now])}
  scope :since, ->(time = Time.new(1970, 1, 1)){where(["starts_at > ?", !time.nil? ? time : ''])}

  def self.pandora_find(scope, params)
    if scope == :all
      if params[:search].present?
        search_query = ["title_en LIKE :q or body_en LIKE :q or title_de LIKE :q or body_de LIKE :q", q: "%#{params[:search]}%"]
      else
        search_query = 'true'
      end

      if params[:current] == true
        if params[:since].present?
          Announcement.current.since(Time.parse(params[:since])).where(search_query).order(updated_at: :desc)
        else
          Announcement.current.where(search_query).order(updated_at: :desc)
        end
      else
        Announcement.where(search_query).order(updated_at: :desc)
      end
    else # :single
      Announcement.find(scope)
    end
  end

  def title
    if I18n.locale == :de
      title_de
    else
      title_en
    end
  end

  def body
    if I18n.locale == :de
      body_de
    else
      body_en
    end
  end

  def expired?
    ends_at < DateTime.now
  end

  def current?
    time = DateTime.now
    starts_at <= time && ends_at >= time
  end

  def allowed?(current_user)
    if role == 'anyone'
      true
    elsif role == 'users'
      if current_user && !current_user.dbuser?
        true
      else
        false
      end
    elsif role == 'admins'
      if current_user && current_user.anyadmin?
        true
      else
        false
      end
    else
      false
    end
  end

  def date
    [starts_at, updated_at].max
  end

  def to_s
    title
  end

  # REWRITE: it has to accept arbitrary arguments
  # def to_json
  def to_json(*a)
    {notification: self.attributes}.to_json
  end

  # def starts_at
  #   if v = read_attribute(:starts_at)
  #     v.localtime
  #   end
  # end

  # REWRITE: we need to define a few accessors since the dates end up in this
  # class as strings
  # def starts_at
  #   if v = attributes["starts_at"]
  #     (v.is_a?(DateTime) || v.is_a?(Time)) ? v : Time.zone.parse(v)
  #   end
  # end
  # def ends_at
  #   if v = attributes["ends_at"]
  #     (v.is_a?(DateTime) || v.is_a?(Time)) ? v : Time.zone.parse(v)
  #   end
  # end
end
