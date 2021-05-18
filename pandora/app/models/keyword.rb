class Keyword < ApplicationRecord

  has_and_belongs_to_many :collections
  has_and_belongs_to_many :sources
  has_and_belongs_to_many :uploads

  validates_presence_of :title

  alias_method :to_param, :to_s

  def self.search(term)
    return all unless term

    where('title LIKE ?', "%#{term}%")
  end

  def self.ensure(title)
    where('BINARY title = ?', title).first || create(title: title)
  end

  def self.from_keyword_list(value)
    return [] if value.blank?

    titles = value.
      split(/\s*\r?\n+\s*/).
      reject{|i| i.blank?}.
      map{|i| i.strip}.
      uniq

    titles.map do |title|
      find_or_initialize_by(title: title)
    end
  end

  def self.to_keyword_list
    map{|k| k.title}.join("\n")
  end

  def object_name

  end

  def to_s
    title
  end

  # used by Util::Resourceful#manage !
  def to_param
    title
  end
end
