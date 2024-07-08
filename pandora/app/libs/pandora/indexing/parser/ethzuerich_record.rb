class Pandora::Indexing::Parser::EthzuerichRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./Bildreferenz/text()').to_s.strip
  end

  def path
    "#{record.at_xpath('./Bildreferenz/text()')}"
  end

  def artist
    record.xpath('./Künstler/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('./Künstler/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./Titel/text()')
  end

  def location
    record.xpath('./Ort/text()')
  end

  def material
    record.xpath('./Technik_Material/text()')
  end

  def date
    record.xpath('./Datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def keyword
    record.xpath('./Sachkatalog/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('./Copyright/text()').map {|right_reproduction|
      HTMLEntities.new.decode(right_reproduction)
    }
  end

  def depository
    record.xpath('./Copyright/text()')
  end
end
