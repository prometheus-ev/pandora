class Indexing::Sources::Ethzuerich < Indexing::SourceSuper
  def records
    document.xpath('//dokument')
  end

  def record_id
    record.xpath('.//Bildreferenz/text()').to_s.strip
  end

  def path
    "#{record.at_xpath('.//Bildreferenz/text()')}"
  end

  # künstler
  def artist
    record.xpath('.//Künstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//Künstler/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # standort
  def location
    record.xpath('.//Ort/text()')
  end

  # material
  def material
    record.xpath('.//Technik_Material/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  # schlagwoerter
  def keyword
    record.xpath('.//Sachkatalog/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//Copyright/text()').map { |right_reproduction|
      HTMLEntities.new.decode(right_reproduction)
    }
  end

  # aufbewahrungsort des negativs
  def depository
    record.xpath('.//Copyright/text()')
  end
end
