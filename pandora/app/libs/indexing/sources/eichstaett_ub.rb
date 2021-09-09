class Indexing::Sources::EichstaettUb < Indexing::SourceSuper
  def records
    document.xpath('//item')
  end

  def record_id
    record.xpath('@id')
  end

  def path
    return miro if miro?

    record.at_xpath('@thumbnail')
  end

  # künstler
  def artist
    record.xpath('.//meta[@name="DC.creator"]/@content')
  end

  def artist_normalized
    an = record.xpath('.//meta[@name="DC.creator"]/@content').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//meta[@name="DC.title"]/@content')
  end

  # datierung
  def date
    record.xpath('.//meta[@name="DC.date"]/@content')
  end

  # institution
  def location
    "#{record.xpath('.//meta[@name="DC.coverage"]/@content')}, #{record.xpath('.//meta[@name="DC.institution"]/@content')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # Beschreibung
  def description
    record.xpath('.//meta[@name="DC.description"]/@content')
  end

  def size
    record.xpath('.//meta[@name="DC.format"]/@content')
  end

  # abbildungsnachweis
  def credits
    "#{record.xpath('.//meta[@name="DC.source"]/@content')}. S. #{record.xpath('.//meta[@name="DC.format-pages"]/@content')}. Abb. #{record.xpath('.//meta[@name="DC.format-illustration"]/@content')}. Taf. #{record.xpath('.//meta[@name="DC.format-table"]/@content')}.".gsub(/ S\. \./, '').gsub(/ Abb\. \./, '').gsub(/ Taf\. \./, '')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
