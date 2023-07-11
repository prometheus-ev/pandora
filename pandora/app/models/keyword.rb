class Keyword < ApplicationRecord

  include Util::Config

  has_many :collection_keyword, dependent: :destroy
  has_many :collections, through: :collection_keyword

  has_many :keyword_source, dependent: :destroy
  has_many :sources, through: :keyword_source

  has_many :keyword_upload, dependent: :destroy
  has_many :uploads, through: :keyword_upload

  validates_presence_of :title, unless: :title_de
  validates_presence_of :title_de, unless: :title

  self.controller_name = 'keywords'

  before_validation do |k|
    if k.title.present?
      k.title.gsub!(/\A[\"'\s\n]+/m, '')
      k.title.gsub!(/[\"'\s\n]+\Z/m, '')
    end
    k.title_de = k.title_de.strip if k.title_de.present?
  end

  # returns all associations, not distinct keywords!
  # def self.type(type = 'upload')
  #   return all if type.blank?

  #   case type.to_s
  #   when 'upload'
  #     joins('LEFT JOIN keywords_uploads ku ON ku.keyword_id = keywords.id').
  #     where('ku.upload_id IS NOT NULL')
  #   when 'source'
  #     joins('LEFT JOIN keywords_sources ks ON ks.keyword_id = keywords.id').
  #     where('ks.source_id IS NOT NULL')
  #   when 'collection'
  #     joins('LEFT JOIN collections_keywords ck ON ck.keyword_id = keywords.id').
  #     where('ck.collection_id IS NOT NULL')
  #   else
  #     raise Pandora::Exception, "unknown keyword type: #{type}"
  #   end
  # end

  # TODO: this is actually not an object-level restriction, so it can be handled
  # by control_access in the controller
  # def self.allowed(user, rw = :read)
  #   return all if user.admin? || user.superadmin?
  # end

  def self.search(column, value)
    return all if column.blank? || value.blank?

    case column
    when 'title' then where("title LIKE :v OR title_de LIKE :v", v: "%#{value}%")
    when 'sounds_like' then where('soundex(title) = soundex(?)', value)
    else
      raise Pandora::Exception, "unknown search column for Keyword: #{column}"
    end
  end

  def self.sorted(column, direction)
    case column
    when 'title' then order(column => direction)
    else
      raise Pandora::Exception, "unknown sort criteria for Keyword: #{column}"
    end
  end

  def self.untranslated
    where("title_de IS NULL OR title_de = '' OR title IS NULL OR title = ''")
  end

  def self.similar
    column = I18n.locale == :en ? 'title' : 'title_de'

    scope =
      select("
        count(*) AS count,
        soundex(#{column}) AS sound
      ").
      group('sound').
      having('count > 1 AND sound IS NOT NULL').
      order('count DESC')

    scope.map do |r|
      {'count' => r['count'], 'sound' => r['sound']}
    end
  end

  def self.by_soundex(values)
    column = I18n.locale == :en ? 'title' : 'title_de'

    scope =
      select("keywords.*, soundex(#{column}) AS sound").
      where("soundex(#{column}) IN (?)", values).
      order("#{column} ASC")

    scope.group_by do |keyword|
      keyword.sound
    end
  end

  def has_whitespace?
    (title.is_a?(String) && title.match?(/(^\s+|\s+$)/)) ||
    (title_de.is_a?(String) && title_de.match?(/(^\s+|\s+$)/))
  end

  def merge(other_ids)
    other_ids -= [self.id]

    return if other_ids.blank?

    c = self.class.connection

    ['keywords_sources', 'keywords_uploads', 'collections_keywords'].each do |t|
      sql = self.class.sanitize_sql_array([
        "UPDATE #{t} SET keyword_id=:new_id WHERE keyword_id IN (:old_ids)",
        new_id: self.id,
        old_ids: other_ids
      ])
      c.execute(sql)
    end

    self.class.where(id: other_ids).destroy_all
  end

  # def self.[](*args)
  #   if args.size == 1 && (arg = args.first).is_a?(String)
  #     # REWRITE: using new query interface
  #     where('BINARY title = ?', arg).first || create(title: arg)
  #     # find(:first, :conditions => ['BINARY title = ?', arg]) || create(:title => arg)
  #   else
  #     find_with_extra(:title, *args)
  #   end
  # end

  def t
    if I18n.locale == :en
      title || title_de
    else
      title_de || title
    end
  end

  def locale_title
    I18n.locale == :en ? title : title_de
  end

  def other_title
    I18n.locale == :en ? title_de : title
  end

  def self.search_columns
    column = I18n.locale == :en ? 'title' : 'title_de'

    [column, 'sounds_like']
  end
end
