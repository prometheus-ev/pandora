class Indexing::SourceSuper < Indexing::SourceParent
  def record_id_original
    record_id
  end

  def miro?
    @miro_record_ids ||= Rails.configuration.x.indexing_warburg_and_miro_record_ids[:miro][name.to_sym]

    if @miro_record_ids.include?(process_record_id(record_id)) && !@create_institutional_uploads
      true
    else
      false
    end
  end

  def miro
    'miro'
  end

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

  def single_date_range(date)
    # darmstadt_tu
    d = date.sub('1880/19010', '1880/1910')

    # ddorf
    d = d.sub('7. Jh. v.Chr. / bis', '7. Jh. v.Chr.')
    d = d.sub('ca. 13480', 'ca. 1380')

    date_range(d)
  end

  private

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

    @file_name = nil
    @date = nil
    @date_range = nil
    @_credits = nil # darmstadt_tu
  end

  def is_object?
    respond_to?('record_object_id')
  end

  def total
    @total ||= `zcat -f '#{@file_name}' | grep -io '<#{@node_name}>' | wc -l`.to_i
  end

  def read
    io = File.open(@file_name)
    reader = Nokogiri::XML::Reader.from_io(io)
    @enumerator = reader.lazy

    # filter irrelevant xml content
    @enumerator = @enumerator.select do |node|
      (@node_name == node.name) &&
      (!@namespace_uri || node.namespace_uri == @namespace_uri) &&
      (node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT)
    end

    @enumerator = @enumerator.map do |node|
      Nokogiri::XML(node.outer_xml, nil, node.encoding).remove_namespaces!
    end
  end
  
  def preprocess_record_object_ids
    @record_object_id_count = {}
    preprocessed = 0

    read

    @enumerator.each do |doc|
      self.record = doc.root
      r_object_id = record_object_id

      unless r_object_id.blank?
        if @record_object_id_count.keys.include?(r_object_id)
          @record_object_id_count[r_object_id] += 1
        else
          @record_object_id_count[r_object_id] = 1
        end
      end

      preprocessed += 1
      printf "#{name}: #{preprocessed}/#{total} (preprocessing...)\r" unless Rails.env.test?
    end
    puts unless Rails.env.test?
  end

  def date_range?
    respond_to?(:date_range) && date_range != nil
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
        @date_ranges_count += 1 if @date_ranges_count

        if @date_range.is_a? HistoricalDating::Range
          @date_range
        else
          @date_range = HistoricalDating.parse(@date_range)

          # TODO: Move to HistoricalDating.
          if @date_range.from > @date_range.to
            raise HistoricalDating::Error, 'Date range from date is newer then date range to date.'
          end

          # otherwise, still return @date_range
          @date_range
        end
      else
        @date_range = nil
      end
    rescue Parslet::ParseFailed, HistoricalDating::Error, Date::Error => e
      # Date::Error occurs for e.g. '31.9.1907'

      if @date_ranges_parse_failed
        @date_ranges_parse_failed << "#{date.inspect} (record ID: #{process_record_id(record_id)})"
        @date_range = nil
      end
    end
  end

  def artist_normalized(artist)
    @artist_attributions ||= Rails.configuration.x.indexing_artist_attributions[:attributions]

    artist = artist.to_a
    artist.map! { |a|
      a = a.to_s.encode(Encoding::UTF_8)

      @artist_attributions.each { |artist_attribution|
        a.delete_prefix!(artist_attribution)
        a.delete_suffix!(artist_attribution)
        a.strip!
      }

      a
    }
  end

  # Check if the current record ID is included in the warburg record IDs.
  #
  # @return [Boolean] Is the current record ID included or not?
  def is_record_id_a_rights_work_warburg_record_id?
    @warburg_record_ids_list ||= Rails.configuration.x.indexing_warburg_and_miro_record_ids[:warburg]

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
    @vgbk_artists_list ||= Rails.configuration.x.indexing_vgbk_artists[:artists]

    is_in_list =
      respond_to?(:artist_normalized) && 
      artist_normalized.to_a.any? { |a|
        @vgbk_artists_list.include?(a.to_s.downcase.encode(Encoding::UTF_8))
      }

    return false unless is_in_list
    return true unless date_range?

    # See #181.
    date_range.to > (Time.now - 170.years)
  end

  # Rights work string indicating a VGBK artist.
  #
  # @return [String] VGBK rights work string.
  def rights_work_vgbk
    'rights_work_vgbk'
  end
end
