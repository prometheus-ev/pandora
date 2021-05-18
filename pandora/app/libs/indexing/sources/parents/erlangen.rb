class Indexing::Sources::Parents::Erlangen < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//Kennung/text()')
  end

  def path
    "#{record.at_xpath('.//Kennung/text()')}.jpg"
  end

  def s_keyword
    [record.xpath('.//Gattung/text()'), record.xpath('.//Material/text()')]
  end

  # künstler
  def artist
    record.xpath('.//Kuenstler/text()')
  end

  def artist_normalized
    super(record.xpath('.//Kuenstler/text()'))
  end

  # titel
  def title
    record.xpath('.//Objektname/text()')
  end

  # material
  def material
    record.xpath('.//Material/text()')
  end

  # gattung
  def genre
    record.xpath('.//Gattung/text()') + record.xpath('.//Gattung/DATA/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  # Bemerkung
  def annotation
    record.xpath('.//Kommentar/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
