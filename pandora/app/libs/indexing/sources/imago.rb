class Indexing::Sources::Imago < Indexing::SourceSuper
  def records
    document.xpath('//entry')
  end

  def record_id
    record.xpath('.//bildnummer/text()')
  end

  def path
    return miro if miro?

    "#{record.at_xpath('.//bildnummer/text()')}".downcase
  end

  def s_location
    [record.xpath('.//standort/text()'), record.xpath('.//institution/text()')]
  end

  def s_credits
    [record.xpath('.//abbildungsnachweis/text()'), record.xpath('.//copyright/text()'), record.xpath('.//fotograf/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map {|a|
      HTMLEntities.new.decode(a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' '))
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    d = date.to_s.strip.encode('iso-8859-1').encode('utf-8')

    if d == '15445-54'
      d = '1545-54'
    elsif d == 'um 14225-26'
      d = 'um 1422-26'
    elsif d == '1909-19012'
      d = '1909-1912'
    elsif d == 'um 134071350'
      d = 'um 1340/1350'
    elsif d == '1961/62/66'
      d = '1961/62;1966'
    end

    super(d)
  end

  # standort
  def location
    "#{record.xpath('.//standort/text()')}, #{record.xpath('.//institution/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # technik
  def technique
    record.xpath('.//technik/text()')
  end

  # format
  def size
    record.xpath('.//format/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//abbildungsnachweis/text()')
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # copyright
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  # fotograf
  def photographer
    record.xpath('.//fotograf/text()')
  end

  # schlagworte
  def keyword
    record.xpath('.//schlagworte/text()')
  end
end
