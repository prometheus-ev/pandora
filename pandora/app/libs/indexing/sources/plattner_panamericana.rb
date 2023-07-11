class Indexing::Sources::PlattnerPanamericana < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    "#{record.xpath('.//pictName[1]/text()')}".gsub(/.tif/, '')
  end

  def path
    "#{record.xpath('.//pictName[1]/text()')}".gsub(/.tif/, '.jpg')
  end

  def s_location
    [record.xpath('.//txtLand/text()'), record.xpath('.//txtOrt/text()')]
  end

  def artist
    record.xpath('.//txtUrheber/text()')
  end

  # titel
  def title
    record.xpath('.//txtTitel/text()')
  end

  # datierung
  def date
    record.xpath('.//txtEntstehungszeit/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # standort
  def location
    "#{record.xpath('.//txtLand/text()')}, #{record.xpath('.//txtOrt/text()')}"
  end

  # beschreibung
  def description
    record.xpath('.//txtBildlegende/text()') +
    record.xpath('.//txtBeschreibung/text()')
  end

  # Fotograf
  def photographer
    "#{record.xpath('.//txtFotograf/text()')} (#{record.xpath('.//txtAufnahmedatum/text()')})".gsub(/\(\)/, '')
  end

  # abbildungsnachweis
  def credits
    "Stiftung Jesuiten weltweit, Zürich, http://jesuiten-weltweit.ch"
  end

  # Kommentar
  def comment
    record.xpath('.//txtBemerkungen/text()')
  end
end
