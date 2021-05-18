class Indexing::Sources::HalleKg < Indexing::SourceSuper
  def records
    document.xpath('//database/table[column[@name="quelle"][text()!="" and text()!=" "]]')
  end

  def record_id
    record.xpath('.//column[@name="bildident"]/text()')
  end

  def s_location
    [record.xpath('.//column[@name="fundort"]/text()'), record.xpath('.//column[@name="ort"]/text()')]
  end

  def s_title
    [record.xpath('.//column[@name="titel"]/text()'), record.xpath('.//column[@name="zusatz"]/text()')]
  end

  def s_unspecified
    [record.xpath('.//column[@name="bemerkungen"]/text()'), record.xpath('.//column[@name="isbn"]/text()')]
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      "#{record.at_xpath('.//column[@name="name"]/text()')}"
    end
  end

  # künstler
  def artist
    record.xpath('.//column[@name="kuenstler"]/text()')
  end

  def artist_normalized
    an = "#{record.xpath('.//column[@name="kuenstler"]/text()')}".split("; ").map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # titel
  def title
    record.xpath('.//column[@name="titel"]/text()')
  end

  # untertitel
  def addition
    record.xpath('.//column[@name="zusatz"]/text()')
  end

  # standort
  def location
    record.xpath('.//column[@name="ort"]/text()')
  end

  def discoveryplace
    record.xpath('.//column[@name="fundort"]/text()')
  end

  # datierung
  def date
    record.xpath('.//column[@name="datierung"]/text()')
  end

  # bildnachweis
  def credits
    record.xpath('.//column[@name="quelle"]/text()')
  end

  def size
    record.xpath('.//column[@name="format"]/text()')
  end

  def material
    record.xpath('.//column[@name="material"]/text()')
  end

  def genre
    record.xpath('.//column[@name="gattung"]/text()')
  end

  def annotation
    record.xpath('.//column[@name="bemerkungen"]/text()')
  end

  def isbn
    record.xpath('.//column[@name="isbn"]/text()')
  end

  def technique
    record.xpath('.//column[@name="technik"]/text()')
  end
end
