class Indexing::Sources::Parents::Mainz < Indexing::SourceSuper
  def records
    document.xpath('//Bild')
  end

  def record_id
    record.xpath('.//p_Bildreferenz/text()')
  end

  def record_object_id
    [name, Digest::SHA1.hexdigest(title.text + location.text)].join('-')
  end

  def path
    "#{record.at_xpath('.//p_Bildreferenz/text()')}"
  end

  def s_location
    [record.xpath('.//p_Standort/text()'), record.xpath('.//p_Herkunftsort/text()')]
  end

  def s_credits
    [record.xpath('.//p_Abbildungsnachweis/text()'), record.xpath('.//p_Copyright-Vermerk/text()')]
  end

  # künstler
  def artist
    record.xpath('.//p_KuenstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('.//p_KuenstlerIn/text()').map { |a|
      a.to_s.gsub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//p_Titel/text()')
  end

  def date
    record.xpath('.//p_Datierung/text()')
  end

  # standort
  def location
    record.xpath('.//p_Standort/text()')
  end

  # material
  def material
    record.xpath('.//p_Material/text()')
  end

  # herkunftsort
  def origin
    record.xpath('.//p_Herkunftsort/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//p_Abbildungsnachweis/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//p_Copyright-Vermerk/text()')
  end
end
