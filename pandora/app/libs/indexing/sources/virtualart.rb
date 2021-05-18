class Indexing::Sources::Virtualart < Indexing::SourceSuper
  def records
    document.xpath('//images_single')
  end

  def record_id
    record.xpath('.//image_file/text()').to_s.gsub(/.*\//, '').gsub(/\..*/, '')
  end

  def path
    "#{record.xpath('.//image_file/text()')}".gsub(/.*\//, '').sub(/.tif\z/, '.jpg')
  end

  def artist
    record.xpath('.//ancestor::note/artist/text()') +
    record.xpath('.//ancestor::note/artist_place/text()')
  end

  def artist_normalized
    super(record.xpath('.//ancestor::note/artist/text()'))
  end

  def title
    "#{record.xpath('.//image_title/text()')} [#{record.xpath('.//ancestor::note/title/text()')}]".gsub(/ \[\]/, '')
  end

  def location
    record.xpath('.//city/text()') +
    record.xpath('.//location/text()')
  end

  def date
    "#{record.xpath('.//ancestor::note/date/text()')}".gsub(/ - 0\z/, '')
  end

  def literature
    (1..(record.at_xpath('.//ancestor::note/lit/@count').to_s.to_i + 1)).map { |index|
      hash = {}
      str = ""
      entries = record.at_xpath(".//ancestor::note/lit/lit_single[#{index}]/lit_bibtex/text()").to_s.scan(/([a-z].*) = \{(.*)\}/)

      entries.map { |element|
        hash.store(element[0],element[1])
      }

      if hash["author"]; str = hash["author"];end
      if hash["title"]; str += ": " + hash["title"] + ", ";end
      if (str2 = hash["booktitle"] || hash["journal"]); str += "in: " + str2 + ", ";end
      if (str3 = hash["number"] || hash["volume"]); str += str3 + ", ";end
      if hash["editor"]; str += "Hg. von " + hash["editor"] + ", ";end
      if hash["publisher"]; str += hash["publisher"] + ", ";end
      if hash["place"]; str += hash["place"] + ", ";end
      if hash["year"]; str += hash["year"] + ", ";end
      if hash["pages"]; str += hash["pages"] + ", ";end
      if hash["isbn"]; str += hash["isbn"] + ", ";end
      if hash["notes"]; str += hash["notes"];end

      str.gsub(/, $/, ".").gsub(/\[datum\]/, '')
    }
  end

  def credits
    record.xpath('.//image_source/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    "Archive of Digital Art (ADA)"
  end

  def source_url
    record.xpath('.//ancestor::note/object_link/text()')
  end
end
