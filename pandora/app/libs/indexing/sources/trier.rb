class Indexing::Sources::Trier < Indexing::SourceSuper
  def records
    document.xpath('//trier')
  end

  def record_id
    record.xpath('.//bildnr/text()')
  end

  # proxy: http://134.95.80.14/proxy/trier/
  def path
    "image.php?id=#{record.at_xpath('.//bildnr/text()')}&type=uge"
  end

  def s_location
    [record.xpath('.//stadt/text()'), record.xpath('.//institution/text()')]
  end

  def s_unspecified
    [record.xpath('.//zusatz/text()')]
  end

  # künstler
  def artist
    ["#{record.xpath('.//vorname/text()')} #{record.xpath('.//name/text()')}"]
  end

  def artist_normalized
    an = artist.map { |a|
      a.strip
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
    record.xpath('.//titel/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  # standort
  def location
    "#{record.xpath('.//stadt/text()')}, #{record.xpath('.//institution/text()')}".gsub(/^, /, '').gsub(/, $/, '')
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # technik
  def technique
    record.xpath('.//technik/text()')
  end

  # gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # format
  def format
    record.xpath('.//format/text()')
  end

  # zusatz
  def addition
    record.xpath('.//zusatz/text()')
  end

  # bildnachweis
  def credits
    record.xpath('.//literatur/text()')
  end

  def isbn
    record.xpath('.//isbn/text()')
  end
end
