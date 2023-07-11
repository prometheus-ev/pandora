# Datenbank wurde ehemals für Literaturverwaltung erstellt
# und die Felder für die Kunstgeschichte zweckentfremdet.
# Die eigenartigen Bezeichnungen sind darauf zurückzuführen.
class Indexing::Sources::MuensterTheologie < Indexing::SourceSuper
  def records
    document.xpath('//datensatz')
  end

  def record_id
    record.xpath('.//eintrag_nr/text()')
  end

  def path
    return miro if miro?

    "#{record.at_xpath('.//signatur/text()')}".split(' ').join('_') << ".jpg"
  end

  def s_location
    [record.xpath('.//archiv_fundus/text()'), record.xpath('.//name_pseudo/text()')]
  end

  def s_credits
    [record.xpath('.//deskriptor/text()'), record.xpath('.//ort_26/text()'), record.xpath('.//verlag_26/text()'), record.xpath('.//band_26/text()'), record.xpath('.//jahr_26/text()'), record.xpath('.//funktion_rolle/text()')]
  end

  # künstler
  def artist
    ["#{record.xpath('.//name_autor/text()')} (#{record.xpath('.//sprache_a/text()')})".gsub(/ \(\)/, '')]
  end

  def artist_normalized
    an = record.xpath('.//name_autor/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//aktueller_titel/text()')
  end

  # standort
  def location
    record.xpath('.//name_pseudo/text()')
  end

  # datierung
  def date
    record.xpath('.//archiv_ort/text()')
  end

  def date_range
    d = date.to_s.strip.encode('iso-8859-1').encode('utf-8')

    if d == '18879/80'
      d = '1879/80'
    end

    super(d)
  end

  # abbildungsnachweis
  def credits
    "#{record.xpath('.//deskriptor/text()')}, #{record.xpath('.//funktion_rolle/text()')}, #{record.xpath('.//ort_26/text()')}, #{record.xpath('.//verlag_26/text()')}, #{record.xpath('.//jahr_26/text()')}, S. #{record.xpath('.//band_26/text()')} | Diathekssignatur: #{record.xpath('.//signatur/text()')}".gsub(/S.  /, '').gsub(/(, ){2,}/, ', ').gsub(/\A, \|/, '')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # material
  def material
    record.xpath('.//in_akte_konvolut/text()')
  end

  # format
  def size
    record.xpath('.//inst_org_abk/text()')
  end

  # schlagworte
  def keyword
    record.xpath('.//schlagwort/text()')
  end

  def signature
    record.xpath('.//signatur/text()')
  end
end
