class XmlTestSourceObjectsRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./Ob_f41/text()')
  end

  def record_object_id
    unless (record_object_id_value = record.at_xpath('./ObjektId/text()')).blank?
      generate_record_id(record_object_id_value.content)
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def artist
    record.xpath('./KünstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('./KünstlerIn/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_parser.normalize(an)
  end

  def title
    record.xpath('./Titel/text()')
  end
end
