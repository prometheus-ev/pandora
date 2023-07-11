class Pandora::Indexing::Parser::DateParser
  def initialize
    @date_ranges_count = 0
    @date_ranges_parse_failed = []
  end

  attr_reader :date_ranges_count
  attr_reader :date_ranges_parse_failed

  def date_range(date)
    if date
      if date.is_a? HistoricalDating::Range
        date_range = date
      else
        date_range = date_range_preprocess(date)
      end
    else
      date_range = nil
    end

    begin
      if date_range
        @date_ranges_count += 1 if @date_ranges_count

        if date_range.is_a? HistoricalDating::Range
          date_range
        else
          date_range = HistoricalDating.parse(date_range)
        end
      else
        date_range = nil
      end
    rescue Parslet::ParseFailed, HistoricalDating::Error, Date::Error => e
      # Date::Error occurs for e.g. '31.9.1907'

      if @date_ranges_parse_failed
        @date_ranges_parse_failed << date.inspect
        date_range = nil
      end
    end
  end

  # TODO Replace this method with a dating preprocessor class/lib.
  def date_range_preprocess(date)
    # This is needed for dates that have a 'to' date with v. Chr. but the 'from' date is missing v. Chr. 
    if date.include? 'bis'
      from_to = date.split('bis')

      if from_to[1] && from_to[1].include?('v. Chr.') && !from_to[0].include?('v. Chr.')
        date.sub! 'bis', 'v. Chr. bis'
      end
    end

    # robertin, see #1065
    date.sub! ' ()', ''
    date.sub! ' .', '.'

    # artemis, see #1066
    date.sub! ' (?)', ''
    date.sub! '(?)', ''
    date.sub! '?', ''
    date.sub! '(Baubeginn)', ''

    # artemis, see #1068
    date.sub! '11727/1767', '1727/1767'

    # dadaweb, see #1069
    date.sub! '1974/19975', '1974/1975'
    date.sub! '1646/16533', '1646/1653'

    # TODO: where does the date '1829. Jh.' come from? Database should correct this.
    date.sub! '1829. Jh.', '1829'

    # heidicon_kg
    date.sub! '1921.', '1921'

    # ffm_conedakor, see #1165
    date.sub! '18525', '1852'
    date.sub! '18401', '1840'
    date.sub! '19013', '1913'

    if date.strip == 'undatiert' ||
        date.strip.blank? ||
        (date.scan(/\D/).empty? && date.length > 4)
      date = nil
    end

    date
  end
end
