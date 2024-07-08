class XmlTestSourceRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//Ob_f41/text()')
  end

  def artist
    record.xpath('.//KünstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('.//KünstlerIn/text()').map do |a|
      a.to_s.split(', ').reverse.join(' ')
    end

    @artist_parser.normalize(an)
  end

  def title
    record.xpath('.//Titel/text()')
  end
end
