# REWRITE: these additions are temporary and should be replaced with other
# implementation once the ugprade is complete

class String
  def t
    if self == ''
      raise ::Pandora::Exception, "the string to be translated can't be empty"
    end

    I18n.t self, globalize: true
  end

  def /(something)
    case something
    when Integer
      self.t.gsub('%d', something.to_s)
    when Array
      self.t % something
    # self.gsub('%_', '%s') % something
    when Proc
      self.t.gsub(/\%\(([^\)]+)\)\%/) do |m|
        something.call(m.gsub(/\%\(|\)\%/, ''))
      end
    when String then self.t.gsub('%s', something)
    when Symbol, Account, Email, Collection, Announcement
      self.t.gsub('%s', something.to_s)
    when ClientApplication, Source
      self.t.gsub('%s', something.name)
    else
      raise "unhandled operand '#{something}' which is a #{something.class.name}"
    end.html_safe
  end

  def tn(namespace)
    I18n.t self, globalize: true, namespace: namespace
  end
end

class Integer
  def loc
    self.to_s
  end

  def localize
    self.to_s
  end
end

class Float
  # REWRITE: unknown purpose
  def loc(n = 2)
    self.to_s
  end
end

class Date
  def loc(format)
    strftime(format)
  end
end

module Locale
  def self.mapping
    {'en-US' => 'en', 'de-DE' => 'de'}
  end

  def self.set_base_language(language)
    I18n.default_locale = mapping[language]
  end

  def self.ext(something = nil)
    ".#{I18n.locale}"
  end

  def self.set(locale)
    if locale.nil?
      I18n.locale = I18n.default_locale
    else
      I18n.locale = mapping[locale]
    end
  end

  def self.switch_locale(locale)
    tmp = I18n.locale
    I18n.locale = locale
    result = yield
    I18n.locale = tmp
    result
  end

  # is any locale active?
  def self.active?
    true
  end

  def self.active
    I18n.locale
  end
end

module Upgrade
  def self.extract_multi_param_date(hash, field)
    str = "#{hash["#{field}(1i)"]}-#{hash["#{field}(2i)"]}-#{hash["#{field}(3i)"]}"
    hash.delete "#{field}(1i)"
    hash.delete "#{field}(2i)"
    hash.delete "#{field}(3i)"
    if str.match(/^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$/)
      hash[field] = Date.parse(str)
    end
  end
end
