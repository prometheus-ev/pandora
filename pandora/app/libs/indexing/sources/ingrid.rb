class Indexing::Sources::Ingrid < Indexing::SourceSuper
  def records
    document.xpath('//graffiti')
  end

  def record_id
    record.xpath('.//ID/text()')
  end

  def path
    "#{record.at_xpath('.//Bildreferenz/text()')}".sub(/https:\/\/media.uni-paderborn.de\//, '')
  end

  # künstler
  def artist
    record.xpath('.//KuenstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('.//KuenstlerIn/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Titel[2]/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  # standort
  def location
    record.xpath('.//Fundort-Stadt/text()')
  end

  def discoveryplace
    "#{record.xpath('.//Fundort-PLZ/text()')} #{record.xpath('.//Fundort-Stadt/text()')}"
  end

  # technik
  def technique
    record.xpath('.//Techniken/text()')
  end

  # Gattung
  def genre
    record.xpath('.//Typen/text()')
  end

  def motif
    record.xpath('.//Motive/text()')
  end

  def carrier_medium
    record.xpath('.//Trägermedien/text()') 
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Quelle/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

end
