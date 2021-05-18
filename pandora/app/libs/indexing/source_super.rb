class Indexing::SourceSuper < Indexing::SourceParent

  def date_range_from
    if date_range
      date_range.from
    else
      nil
    end
  end

  def date_range_to
    if date_range
      date_range.to
    else
      nil
    end
  end

  def rating_count
    nil
  end

  def rating_average
    nil
  end

  def comment_count
    nil
  end

  def user_comments
    nil
  end

  private

  # TODO Replace this method with a dating preprocessor class/lib.
  def date_range_preprocess(date)
    # This is needed for dates that have a 'to' date with v. Chr. but the 'from' date is missing v. Chr. 
    if date.include? 'bis'
      from_to = date.split('bis')

      if from_to[1].include?('v. Chr.') && !from_to[0].include?('v. Chr.')
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

  def keyword_artigo(filename)
    unless @keywords_document
      keywords_file = File.open(File.join(Rails.configuration.x.dumps_path, "artigo_tags", filename))
      @keywords_document = Nokogiri::XML(File.open(keywords_file)) do |config|
        config.noblanks
      end
    end

    @keywords_by_id ||= begin
      results = {}
      @keywords_document.xpath("//artwork").each do |artwork|
        keywords = []
        artwork.xpath('.//tag').each do |tag|
          name = tag.at_xpath("@name").to_s
          language = tag.at_xpath("@language").to_s
          count = tag.at_xpath("@count").to_s
          keywords << "#{name},#{language},#{count}"
        end
        results[artwork['id']] = keywords
      end
      results
    end

    @keywords_by_id[record_id.to_s]
  end

  protected

  # TODO This method is a first step in separating sources from the source_parent class.
  # Source records should be an instance of a source class. The source_parent should rather
  # be an indexer.
  def init(record)
    self.record = record

    @date = nil
    @date_range = nil
  end

  def date_range?
    date_range
  end

  def artist_normalized(artist)
    @artist_attributions ||= Rails.configuration.x.indexing_artist_attributions['attributions']

    artist.to_a.map! { |a|
      a = a.to_s.encode(Encoding::UTF_8)

      @artist_attributions.each { |artist_attribution|
        a.delete_prefix!(artist_attribution)
        a.delete_suffix!(artist_attribution)
        a.strip!
      }

      a
    }
  end

  def date_range(date)
    if @date_range
      return @date_range
    else
      if date
        if date.is_a? HistoricalDating::Range
          @date_range = date
        else
          @date_range = date_range_preprocess(date)
        end
      else
        @date_range = nil
      end
    end

    begin
      if @date_range
        @date_ranges_count += 1

        if @date_range.is_a? HistoricalDating::Range
          @date_range
        else
          @date_range = HistoricalDating.parse(@date_range)
        end
      else
        @date_range = nil
      end
    rescue Parslet::ParseFailed, HistoricalDating::Error => e
      @date_ranges_parse_failed << "#{date.inspect} (record ID: #{record_id})"

      @date_range = nil
    end
  end

  # Check if the current record ID is included in the warburg record IDs.
  #
  # @return [Boolean] Is the current record ID included or not?
  def is_record_id_a_rights_work_warburg_record_id?
    @warburg_record_ids_list ||= Rails.configuration.x.athene_search_record_ids['warburg']

    if @warburg_record_ids_list.include?(process_record_id(record_id))
      true
    else
      false
    end
  end

  # Rights work string indicating a warburg record ID.
  #
  # @return [String] Warburg rights work string.
  def rights_work_warburg
    'rights_work_warburg'
  end

  # Check if any VGBK artist is included in the VGBK artists list.
  #
  # @return [Boolean] Is any artist included or not?
  def is_any_artist_in_vgbk_artists_list?
    @vgbk_artists_list ||= Rails.configuration.x.indexing_vgbk_artists['artists']

    if respond_to?(:artist_normalized) && artist_normalized.to_a.any? { |a| @vgbk_artists_list.include?(a.to_s.downcase.encode(Encoding::UTF_8)) }
      if respond_to?(:date_range) && date_range?
        if date_range.to > (Time.now - 100.years)
          true
        else
          false
        end
      else
        true
      end
    else
      false
    end
  end

  # Rights work string indicating a VGBK artist.
  #
  # @return [String] VGBK rights work string.
  def rights_work_vgbk
    'rights_work_vgbk'
  end

end
