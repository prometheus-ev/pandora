class Indexing::Sources::BerlinIkbFarbdias < Indexing::SourceSuper

  def records
    document.xpath('.//row[contains(bearbeitungsstand, "Erfassungsstufe II")]')
  end

  def record_id
    record.xpath('.//Ressourcen-ID/text()')
  end

  def path
    "Scaler?&dh=2000&fn=#{record.at_xpath('.//bildvollbilddigilib/text()')}"
  end

  # for keeping the separator: string.split(/(?<=\)), /)
  def artist
    artists = "#{record.xpath('.//objektknstler/text()')}".gsub(/ \(Q0\)/,'').split(/(?<=\)),/)
    add_wikidata(artists)
  end


  def title
    titles = "#{record.xpath('.//objektbezeichnung/text()')}".gsub(/ \(Q0\)/,'').split(/(?<=\)),/)
    add_wikidata(titles)
  end

  def detail
    record.xpath('.//bilddetailbildauschn/text()')
  end

  def description
    record.xpath('.//diabeschreibung/text()')
  end

  def location
    locations = "#{record.xpath('.//objektort/text()')}, #{record.xpath('.//objektmuseumsammlung/text()')}".gsub(/ \(Q0\)/,'').gsub(/, \z/, '').gsub(/\A, /, '').split(/(?<=\)),/)
    add_wikidata(locations)
  end

  def taxonomy
    record.xpath('.//systematik/text()')
  end

  # no need
  #def inscription
  #  record.xpath('.//beschriftung/text()')
  #end

  def labels_collection
    record.xpath('.//stempelsammlung/text()')
  end

  def labels_creator
    record.xpath('.//stempelhersteller/text()')
  end

  def slide_creator
    record.xpath('.//diahersteller/text()')
  end

  def date
    object_date = record.xpath('.//objektdatierung/text()').to_s.strip
    image_date = record.xpath('.//bilddatierung/text()').to_s.strip

    if !object_date.blank? && !image_date.blank?
      "#{record.xpath('.//objektdatierung/text()')} (Foto: #{record.xpath('.//bilddatierung/text()')})".gsub(/\A /,'').gsub(/ 00:00/,'').gsub(/-00-00/,'').gsub(/\(Foto: \)/,'')
    elsif !object_date.blank?
      "#{record.xpath('.//objektdatierung/text()')}".gsub(/\A /,'').gsub(/ 00:00/,'').gsub(/-00-00/,'').gsub(/\(Foto: \)/,'')
    elsif !image_date.blank?
      "(Foto: #{record.xpath('.//bilddatierung/text()')})".gsub(/\A /,'').gsub(/ 00:00/,'').gsub(/-00-00/,'').gsub(/\(Foto: \)/,'')
    end
  end

  def date_range
    # Preprocess.
    object_date = record.xpath('.//objektdatierung/text()').to_s.strip

    if !object_date.blank? && object_date != '2.-3. Jh. n. Chr.'
      super(object_date)
    end
  end

  def credits
    ["#{record.xpath('.//title/text()')},https://rs.cms.hu-berlin.de/ikb_mediathek/pages/view.php?ref=#{record.xpath('.//Ressourcen-ID/text()')}"]
  end

  def external_references
    record.xpath('.//externereferenzenzbh/text()')
  end

  def license
    record.xpath('.//lizenz/text()')
  end

  def comment
    record.xpath('.//bemerkungen/text()')
  end

  def rights_reproduction
    license = "#{record.xpath('.//lizenz/text()')}".gsub(/ \(https/,',https').gsub(/\)\z/,'')
    if !(wikidata = "#{record.xpath('.//bildfotograf/text()')}".match(/\(Q.*\)/).to_s.gsub(/\(/,'').gsub(/\)/,'')).blank?
      ["#{record.xpath('.//bildfotograf/text()').to_s.split(/\(Q/)[0]} (Wikidata: %#{wikidata},https://www.wikidata.org/wiki/#{wikidata}%)", "#{license}"]
    else
      ["#{record.xpath('.//bildfotograf/text()')}", "#{license}"]
    end
  end

  def rights_work
    record.xpath('.//lizenzwerk/text()')
  end

  def status_record
    record.xpath('.//bearbeitungsstand/text()')
  end

  def annotations
    record.xpath('.//notes/text()')
  end

  def keywords
    record.xpath('.//keywords/text()')
  end

  def person
    persons = "#{record.xpath('.//objektabgebperson/text()')}".gsub(/ \(Q0\)/,'').split(/(?<=\)),/)
    add_wikidata(persons)
  end

  def source_url
    "https://rs.cms.hu-berlin.de/ikb_mediathek/pages/view.php?ref=#{record.xpath('.//Ressourcen-ID/text()')}"
  end

  private

  def add_wikidata(values)
    values.map{ |value|
      if !(wikidata = value.strip.match(/\(Q\d*\)/).to_s.gsub(/\(/,'').gsub(/\)/,'')).blank?
        "#{value.split(/\(Q/)[0]} (Wikidata: %#{wikidata},https://www.wikidata.org/wiki/#{wikidata}%)"
      else
        "#{value}"
      end
    }
  end

end
