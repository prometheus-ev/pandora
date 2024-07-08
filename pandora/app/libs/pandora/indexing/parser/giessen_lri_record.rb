class Pandora::Indexing::Parser::GiessenLriRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./record_id/text()')
  end

  def path
    "#{record.at_xpath('./image_id/text()')}.jpg"
  end

  def title
    record.xpath('./titel/text()')
  end

  def subtitle
    record.xpath('./untertitel/text()')
  end

  def date
    record.xpath('./Erscheinungs-Datum/text()') +
    record.xpath('./Erscheinungsdatum/text()') +
    record.xpath('./Ereignis-Datum/text()') +
    record.xpath('./Ereignisdatum/text()')
  end

  def date_range
    return @date_range if @date_range

    d = record.xpath('./Erscheinungs-Datum/text()').to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def location
    record.xpath('./standort/text()') +
    record.xpath('./Standort/Inventarnummer/text()') +
    record.xpath('./Erscheinungs-Ort/text()') +
    record.xpath('./Erscheinungsort/text()') +
    record.xpath('./Ereignis-Ort/text()') +
    record.xpath('./Ereignisort/text()')
  end

  def technique
    record.xpath('./technik/text()')
  end

  def material
    record.xpath('./material/text()')
  end

  def size
    record.xpath('./size/text()')
  end

  def inscription
    record.xpath('./inschrift/text()')
  end

  def keyword
    keywords = (record.xpath("./Motiv-Schlagworte/text()") +
                record.xpath("./Motiv-Schlagworte/item/text()") +
                record.xpath("./Sach-Schlagworte/text()")).to_a
    keywords.map!{|keyword| keyword.inner_text}
    keywords.delete_if{|keyword| keyword.blank?}
  end

  def language
    record.xpath('./sprachen/text()')
  end

  # copyright
  def image_code
    record.xpath('./image_id/text()')
  end

  def annotation
    record.xpath('./bemerkungen/text()')
  end

  def credits
    "#{record.xpath('./bemerkungen/text()')}".sub!(
      /.*(?:Quelle|Literatur):\s(.*?)(?:\s{4}|$).*/m, '\1'
    ) || "zu erfragen beim Lexikon der Revolutionsikonographie"
  end
end
