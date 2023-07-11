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

  def date_range
    d = date.to_s.strip

    if d == 'um 1865-19866'
      d = 'um 1865-1866'
    elsif d == '320 - 330. n. Chr.'
      d = '320 - 330 n. Chr.'
    elsif d == 'Um 1190/1200.'
      d = 'Um 1190/1200'
    elsif d == 'Um 1070.'
      d = 'Um 1070'
    elsif d == 'Zwischen 963 und 969.'
      d = 'Zwischen 963 und 969'
    elsif d == 'Zwischen 913 und 920.'
      d = 'Zwischen 913 und 920'
    elsif d == 'Um 1080.'
      d = 'Um 1080'
    elsif d == '1212.'
      d = '1212'
    elsif d == 'Zwischen 1282 und 1304.'
      d = 'Zwischen 1282 und 1304'
    elsif d == 'Um 1260/1270.'
      d = 'Um 1260/1270'
    end

    super(d)
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
