class String
  def enclose_by(prefix, suffix = prefix)
    empty? ? self : "#{prefix}#{self}#{suffix}"
  end

  def quote(condition = "\s", mark = '"')
    condition == true || include?(condition) ? enclose_by(mark) : self
  end

  def parenthesize
    enclose_by('(', ')')
  end

  # Instead of capitalizing only the _first_ word in _str_ like
  # String#capitalize does, capitalizes _all_ words.
  def humanize_all
    dup.humanize_all!
  end

  # Destructive version of #humanize_all.
  def humanize_all!
    gsub!(/_id\z/, '')
    tr!('_', ' ')

    gsub!(/\b\w/){|s| s.upcase!}

    self
  end

  def to_filename(ext = nil)
    ext = case ext
    when nil        then ''
    when /.*\/(.*)/ then '.' << $1
    when /\./       then ext
    when String     then '.' << ext
    else raise TypeError, "String expected, got #{ext.class}"
    end

    str = dup
    str.replace_diacritics!
    str.gsub!(/(?:[^a-zA-Z0-9]|_)+/, '_')
    str.gsub!(/\A_+|_+\z/, '')
    str << ext
  end

  # XML escaped version of to_s
  # REWRITE: this used to be a lot more difficult without utf-8 support and
  # additional libraries were needed. Now that we have it, we (probably) just
  # need to replace "'<>&
  # def to_xs
  #   unpack('U*').map {|n| n.xchr}.join # ASCII, UTF-8
  # rescue
  #   unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
  # end
  def to_xs
    patterns = {
      '"' => '&quot;',
      "'" => '&apos;',
      '<' => '&lt;',
      '>' => '&gt;',
      '&' => '&amp;'
    }

    self.gsub /['"<>&]/ do |m|
      patterns[m]
    end
  end

  def capitalize_first
    empty? ? self : self[0..0].upcase << self[1..-1]
  end
end
