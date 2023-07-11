class TestSourceNestedFields < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def path
    record.at_xpath('.//path/text()')
  end

  def artist
    artist_nested.map { |artist|
      artist['name']
    }.join(' | ')
  end

  def artist_nested
    record.xpath('.//artists/artist').map do |artist|
      doc = {
        "name" => artist.text,
        "dating" => artist['dating'],
        "wikidata" => artist['wikidata']
      }.compact
    end
  end

  def artist_normalized
    super([artist])
  end

  def title
    record.xpath('.//title/text()')
  end

  def location_nested
    record.xpath('.//locations/location').map do |location|
      {
        'name' => location.text,
        'wikidata' => location['wikidata']
      }
    end
  end

  def date
    record.xpath(".//date/text()")
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath(".//rights-reproduction/text()")
  end
end
