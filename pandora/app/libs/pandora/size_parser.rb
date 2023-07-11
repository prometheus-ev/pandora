class Pandora::SizeParser
  def safe_parse(input)
    input = input.first if input.is_a?(Array)
    parse(input)
  rescue StandardError => e
    nil
  end

  def parse(input)
    numbers = extract_numbers(input)
    units = extract_units(input)

    height, width = numbers
    unit = units.first

    # no numbers found
    return nil if width.nil?

    # use the only number found also for height
    height ||= width

    case unit
    when 'cm' # do nothing
    when 'mm'
      width /= 10.0
      height /= 10.0
    when 'in'
      width *= 2.54
      height *= 2.54
    when 'm'
      width *= 100.0
      height *= 100.0
    else
      # we don't know the unit -> can't parse
      return nil
    end

    result = {
      'width' => width,
      'height' => height
    }
  end

  def extract_numbers(input)
    results = []

    # integer with fraction
    results += input.scan(/[\d,.]+ \d+\/\d+/).map do |str|
      inch, frac = str.split(' ')
      n, d = frac.split('/')
      (inch.to_i + n.to_f / d.to_f)
    end

    # decimal
    results += input.scan(/[\d,.]+/).map do |str|
      str.gsub(',', '.').to_f
    end

    results
  end

  def extract_units(input)
    results = []

    delim = /[ .,;\-\(\)\n\d]|$|^/
    patterns = /(cm|mm|millimeters?|meters?|mètres?|in|inch(?:es)?)/

    results = input.scan(/#{delim}#{patterns}#{delim}/i).flatten.map do |str|
      next 'cm' if str == 'cm'
      next 'mm' if str == 'mm' || str.match?(/^millimeters?$/)
      next 'm' if str == 'm' || str.match?(/^meters?$/) || str.match?(/^mètres?$/)
      next 'in' if str == 'in' || str.match?(/^inch(es)?$/)

      str
    end

    results
  end
end
