class Indexing::Sources::Kassel < Indexing::SourceSuper
  def records
    document.xpath("//row")
  end

  def record_id
    [record.xpath(".//bild_nr/text()"), record.xpath(".//inventar_nr/text()")]
  end

  def path
    "#{record.at_xpath(".//bild_nr/text()")}.jpg"
  end

  def artist
    record.xpath(".//kuenstler/text()")
  end

  def artist_normalized
    an = record.xpath(".//kuenstler/text()").map { |a|
      a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  def title
    record.xpath(".//titel").text
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def keyword
    record.xpath(".//objekt/text()")
  end

  def location
    "Staatliche Museen Kassel (Graphische Sammlung)"
  end

  def genre
    record.xpath(".//gattung/text()")
  end

  def date
    record.xpath(".//datierung/text()")
  end

  def source_url
    "http://217.7.90.92:8080/dfg/MuseumKasselController?action=show&objid=#{record.xpath(".//objekt_id/text()")}"
  end
end
