class Indexing::Sources::Genf < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//HA_FICHES_ID/text()')
  end

  def path
    return miro if miro?

    "HISBinObjH_P?ID1=#{record.xpath('.//HA_FICHES_ID/text()')}"
  end

  # künstler
  def artist
    record.xpath('.//HA_AUTEUR_NOM/text()').map { |artist|
      HTMLEntities.new.decode(artist).split("; ")
    }.flatten
  end

  def artist_normalized
    an = artist.map { |a|
      a.sub(/ \(.*/, '').strip.gsub(/Ä/, 'ä').gsub(/Ö/, 'ö').gsub(/Ü/, 'ü').split(', ').reverse.join(" ")
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//DESCRIPTION/text()')
  end

  # datierung
  def date
    record.xpath('.//DATATION/text()')
  end

  # groesse
  def size
    record.xpath('.//FORMAT/text()')
  end

  # standort
  def location
    record.xpath('.//HA_LOCALISATIONS/HA_LOCALISATIONS_ROW/LOCALISATION/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//SOURCE/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
