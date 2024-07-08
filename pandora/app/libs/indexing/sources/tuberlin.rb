class Indexing::Sources::Tuberlin < Indexing::SourceSuper
  def records
    document.xpath('//dump')
  end

  def record_id
    record.xpath('.//bildreferenz/text()')
  end

  def path
    return miro if miro?

    record.at_xpath('.//bildreferenz/text()')
  end

  def s_location
    [record.xpath('.//standort/text()'), record.xpath('.//institution/text()'), record.xpath('.//herkunftsort/text()')]
  end

  def s_credits
    [record.xpath('.//abbildungsnachweis/text()'), record.xpath('.//copyright/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
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

    if d == '1000-12000'
      d = '1000-1200'
    end

    super(d)
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # institution
  def institution
    record.xpath('.//institution/text()')
  end

  # herkunft
  def origin
    record.xpath('.//herkunftsort/text()')
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//abbildungsnachweis/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  # format
  def size
    record.xpath('.//abmessung/text()')
  end
end
