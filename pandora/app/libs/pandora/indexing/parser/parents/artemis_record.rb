class Pandora::Indexing::Parser::Parents::ArtemisRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('@nr')
  end

  def path
    "?C=#{record.at_xpath('@nr')}".gsub(/M0*/, '')
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('.//kuenstler/text()').map{ |a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  # titel
  def title
    title_version = record.xpath('.//titel/@version/text()').to_a.join(" | ")
    if title_version.blank?
      record.xpath('.//titel/text()').to_a.join(" | ")
    else
      record.xpath('.//titel/text()').to_a.join(" | ") + " (" + title_version + ")"
    end
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    @date_range ||= @date_parser.date_range(date.to_s)
  end

  # groesse
  def size
    record.xpath('.//groesse/text()')
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # institution
  def institution
    record.xpath('.//einrichtung/text()')
  end

  # gattung
  def genre
    "#{record.xpath('.//gattung/text()')}, #{record.xpath('.//bildgattung/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # material
  def material
    "#{record.xpath('.//farbe/text()')}, #{record.xpath('.//traeger/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//nachweis/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  # Sachbegriff
  def keyword
    "#{record.xpath('.//bildgattung/text()')}, #{record.xpath('.//sachbegriff/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def keyword_artigo
    @artigo_parser.keywords(record_id)
  end

  # Bemerkung
  def comment
    record.xpath('.//bemerkung/text()')
  end

  def iconclass
    record.xpath('.//iconclass/text()')
  end
end
