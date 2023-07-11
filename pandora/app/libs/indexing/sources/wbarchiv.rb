class Indexing::Sources::Wbarchiv < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    [record.xpath('.//recordid/text()').to_s, record.xpath('.//bilddatei/text()').to_s]
  end

  def path
    "#{record.at_xpath('.//bilddatei/text()')}.jpg"
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map { |a|
      a.to_s.split('; ').map { |i|
        i.split(', ').reverse.join(' ')
      }
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//objekt/text()')
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # bildnachweis
  def credits
    "#{record.xpath('.//bildquelle/text()')} (#{record.xpath('.//datenbank/text()')})".gsub(/ \(\)/, '')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # schlagwörter
  def keyword
    record.xpath('.//stichworte/text()')
  end
end
