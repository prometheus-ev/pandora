class Indexing::Sources::PassauDilps < Indexing::SourceSuper

  def records
    document.xpath('//row')
  end

  def record_id
    @mapping ||= begin
      ids_file = File.open(File.join(Rails.configuration.x.dumps_path, "passau_dilps_ids"))
      ids_document = Nokogiri::XML(File.open(ids_file)) do |config|
        config.noblanks
      end

      result = {}
      ids_document.xpath('//row').each do |e|
        id = e.xpath('imageid').text
        dilps_id = e.xpath('id').text
        if id.present? && dilps_id.present?
          result[id] = dilps_id
        end
      end
      result
    end

    text = "#{record.xpath('.//Original_Dateiname/text()')}"

    if text.blank?
      record.xpath('.//Ressourcen-ID_s_/text()')
    else
      current_id = text.sub(/^1-/, "").sub(/.jpg/, "")
      @mapping[current_id] || current_id
    end
  end

  def path
    return miro if miro?

    "download.php?ref=#{record.xpath('.//Ressourcen-ID_s_/text()')}" 
  end

  def date
    record.xpath('.//oldDate/text()')
  end

    # künstler
  def artist
    record.xpath('.//Urheber/text()')
  end

  def artist_normalized
    super(artist)
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # standort
  def location
    (record.xpath('.//location/text()') + record.xpath('.//institution/text()') + record.xpath('.//Land/text()')).map { |location_term|
      location_term.to_s.strip
    }.delete_if { |location_term|
      location_term.blank?
    }.join(", ")
  end

  # isbn
  def isbn
    record.xpath('.//ISBN/text()')
  end

  # bildnachweis
  def credits
    "#{record.xpath('.//literature/text()')}" +
    " S. #{record.xpath('.//page/text()')}, ".gsub(/ S\. ,/, '') +
    " Abb. #{record.xpath('.//figure/text()')}.".gsub(/ Abb\. \./, '') +
    " Taf. #{record.xpath('.//book_table/text()')}.".gsub(/ Taf\. \./, '')
  end

  def size
    record.xpath('.//format/text()')
  end

  def material
    record.xpath('.//material/text()')
  end

  def technique
    record.xpath('.//technique/text()')
  end

  def keyword
    record.xpath('.//Keywords_-_Subject/text()')
  end

  def addition
    record.xpath('.//Beschriftung/text()')
  end
  
  def genre
    record.xpath('.//Urheber/text()')
  end

  # Bemerkung
  def annotation
    record.xpath('.//Anmerkungen/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//imagerights/text()')
  end

end
