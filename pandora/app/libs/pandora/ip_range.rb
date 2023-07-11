class Pandora::IpRange
  def initialize(from, to, options = {})
    @from = from.to_range.first
    @to = to.to_range.last
    @options = options.reverse_merge! version: 4, exclude: false
  end

  attr_reader :from, :to, :options

  def ==(other)
    return false if other == :invalid
    from == other.from && to == other.to && options == other.options
  end

  def exclude!
    @options[:exclude] = true
  end

  def contains?(ip)
    !@options[:exclude] && matches?(ip)
  end

  def excludes?(ip)
    @options[:exclude] && matches?(ip)
  end

  def matches?(ip)
    ip = self.class.to_ip(ip)
    options[:version] == (ip.ipv4? ? 4 : 6) &&
    from.to_i <= ip.to_i &&
    to.to_i >= ip.to_i
  end

  def self.parse(str)
    do_parse(str)
  rescue Pandora::Exception => e
    :invalid
  end

  def self.do_parse(str)
    str = str.strip
    a = nil
    b = nil

    # handle exclusions
    if str.match(/^-/)
      result = do_parse(str.gsub /^-/, '')
      result.exclude!
      return result
    # handle cases parsable by IPAddr (ruby stdlib)
    elsif ip = to_ip(str)
      a = ip
      b = ip
    # 10.0.50.70-10.0.50.80
    elsif str.match(/(\d+\.){3}\d+-(\d+\.){3}\d+/)
      a, b = str.split('-')
      a = to_ip(a)
      b = to_ip(b)
    # 10.0.50-10.0.60
    elsif str.match(/(\d+\.){2}\d+-(\d+\.){2}\d+/)
      a, b = str.split('-')
      a = to_ip(a)
      b = to_ip(b)
    else
      # 10.10.50.70-80, 10.10-20.50.70-80 etc.
      a = to_ip(str.split('.').map{|e| e.split('-').first}.join('.'))
      b = to_ip(str.split('.').map{|e| e.split('-').last}.join('.'))
    end

    if !a || !b
      raise Pandora::Exception, "invalid range: #{str}"
    end

    return new(a, b)
  end

  def self.to_ip(str)
    # 10.0
    str.gsub! /^(\d+\.)\d+$/, '\0.0.0/16'

    # 10.0.50
    str.gsub! /^(\d+\.){2}\d+$/, '\0.0/24'

    IPAddr.new(str)
  rescue IPAddr::InvalidAddressError => e
    nil
  end
end
