class Role < ApplicationRecord
  has_and_belongs_to_many :accounts

  validates_presence_of :title
  validates_format_of :title, {
    :with => /\A#{LETTER_RE}/,
    :message => 'must begin with a letter'
  }
  validates_uniqueness_of :title, case_sensitive: true

  def self.allowed_roles_for(*roles)
    @roles_by_title ||= begin
      hash = {}
      all.each{|role| hash[role.title] = role}
      hash.freeze
    end

    @allowed_roles_for ||= begin
      hash = {}

      @roles_by_title.keys.each{|role| hash[role] = []}

      hash.update(
        'superadmin' => hash.keys,
        'admin' => %w[useradmin user dbadmin webadmin visitor subscriber],
        'useradmin' => %w[user] # visitor?
      )
    end

    roles = [*roles].flatten.map{|r| r.title}.uniq

    @allowed_roles_for[roles.sort] ||= begin
      allowed = []
      roles.each{|role| allowed.concat(@allowed_roles_for[role])}
      allowed.uniq.map{|role| @roles_by_title[role]}
    end
  end

  def self.allowed?(source_roles, target_roles)
    (target_roles - allowed_roles_for(source_roles)).empty?
  end

  def to_s
    title
  end

  alias_method :to_param, :to_s

  def allowed_roles
    @allowed_roles ||= self.class.allowed_roles_for(self)
  end
end
