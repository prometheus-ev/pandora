class Indexing::Sources::Mka < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def path
    "servlet/return/#{record.at_xpath('.//id/text()')}.jpg?oid=#{record.at_xpath('.//id/text()')}&dimension=1"
  end

  def s_keyword
    [record.xpath('.//keywords/text()'), record.xpath('.//category/text()')]
  end

  def s_material
    [record.xpath('.//copyright/text()'), record.xpath('.//caption/text()'), record.xpath('.//productionformat/text()')]
  end

  # künstler
  def artist
    record.xpath('.//author/text()')
  end

  def artist_normalized
    super(artist)
  end

  # titel
  def title
    record.xpath('.//headline/text()')
  end

  # datierung
  def date
    record.xpath('.//year/text()')
  end

  # land
  def country
    record.xpath('.//countryname/text()')
  end

  # gattung
  def genre
    record.xpath('.//category/text()')
  end

  # produktionsformat
  def format
    record.xpath('.//productionformat/text()')
  end

  # länge
  def length
    record.xpath('.//misc/text()')
  end

  # farbe
  def colour
    record.xpath('.//copyright/text()')
  end

  # ton
  def sound
    record.xpath('.//caption/text()')
  end

  # schlagwörter
  def keyword
    record.xpath('.//keywords/text()')
  end

  def location
    @_institution ||= 'imai - inter media art institute'
  end

  def rights_reproduction
    location
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end


  def credits
    location
  end

  # Datensatz in Quelldatenbank
  def source_url
    "http://89.107.70.240/servlet/objecthandling?oid=#{record.xpath('.//id/text()')}"
  end
end
