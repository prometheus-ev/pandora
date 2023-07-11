class Indexing::Sources::Ppo < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//bildnr/text()')
  end

  def path
    "bildarchiv/#{record.at_xpath('.//bildnr/text()')}.jpg"
  end

  def s_keyword
    [record.xpath('.//epochensw/text()'), record.xpath('.//epoche/text()'), record.xpath('.//format/text()'), record.xpath('.//formsw/text()'), record.xpath('.//freiessw/text()'), record.xpath('.//geosw/text()'), record.xpath('.//sachsw/text()'), record.xpath('.//persw/text()')]
  end

  def s_artist
    [record.xpath('.//kuenstler/text()'), record.xpath('.//stecher/text()')]
  end

  def s_title
    [record.xpath('.//titel/text()'), record.xpath('.//unterschrift/text()'), record.xpath('.//fingtitel/text()')]
  end

  def s_description
    [record.xpath('.//erlaeuterung/text()'), record.xpath('.//beschreibung/text()')]
  end

  def s_location
    [record.xpath('.//ort/text()'), record.xpath('.//standort/text()'), record.xpath('.//koerperschaft_geb/text()')]
  end

  def s_credits
    [record.xpath('.//quelle.titel/text()'), record.xpath('.//quelle.titel_uebergeordnet/text()'), record.xpath('.//quelle.verfasser/text()'), record.xpath('.//quelle.erschort/text()'), record.xpath('.//quelle.erschjahr/text()'), record.xpath('.//rechte/text()')]
  end

  def s_genre
    [record.xpath('.//formsw/text()'), record.xpath('.//format/text()')]
  end

  def s_date
    [record.xpath('.//entstjahr/text()'), record.xpath('.//entstjahr_orig/text()'), record.xpath('.//epoche/text()'), record.xpath('.//epochensw/text()')]
  end

  def s_unspecified
    [record.xpath('.//inschrift/text()'), record.xpath('.//unterschrift/text()'), record.xpath('.//vorlage/text()'), record.xpath('.//bildsignatur/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # stecher
  def engraver
    record.xpath('.//stecher/text()')
  end

  # titel
  def title
    record.xpath('.//titel/text()') + record.xpath('.//fingtitel/text()')
  end

  # datierung
  def date
    record.xpath('.//entstjahr/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # datierung_original
  def date_original
    record.xpath('.//entstjahr_orig/text()')
  end

  # epoche
  def epoch
    record.xpath('.//epoche/text()')
  end

  # herkunft
  def corporate_body
    "#{record.xpath('.//koerperschaft_geb/text()')}, #{record.xpath('.//koerperschaft_ungeb/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # technik
  def technique
    record.xpath('.//format/text()')
  end

  # bildsignatur
  def signature
    record.xpath('.//bild_signatur/text()')
  end

  # vorlage
  def pattern
    record.xpath('.//vorlage/text()')
  end

  # bildunterschrift/~überschrift
  def caption
    record.xpath('.//unterschrift/text()')
  end

  # bildinschrift
  def inscription
    record.xpath('.//inschrift/text()')
  end

  # bildbeschreibung (quelle)
  def description_source
    record.xpath('.//erlaeuterung/text()')
  end

  # bildbeschreibung
  def description
    record.xpath('.//beschreibung/text()')
  end

  # schlagwort (allgemein)
  def keyword_general
    ("#{record.xpath('.//freiessw/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//geosw/text()')}; ".gsub(/\A; /, '') +
     "#{record.xpath('.//sachsw/text()')}").gsub(/; \z/, '').gsub(/, \z/, '')
  end

  # personenschlagwort
  def keyword_person
    record.xpath('.//persw/text()')
  end

  # abbildungsnachweis
  def credits
    ("#{record.xpath('.//quelle/verfasser/text()')}: ".gsub(/\A: /, '') +
     "#{record.xpath('.//quelle/titel/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//quelle/erschort/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//quelle/erschjahr/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//quelle/seite/text()')}. ").sub(/: \. \z/, '. ').gsub(/\A\. /, '') +
    "In: #{record.xpath('.//quelle/titel_uebergeordnet/text()')}".gsub(/In: \z/, '')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht (kürzel)
  def rights_reproduction
    record.xpath('.//rechte/text()')
  end

  def source_url
    "http://www.bbf.dipf.de/cgi-opac/bil.pl?t_direct=x&fullsize=yes&f_IDN=#{record.xpath('.//recordid/text()')}"
  end
end
