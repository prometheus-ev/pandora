class Indexing::Sources::HeidiconKm < Indexing::Sources::Parents::Heidicon
  def pool_name
    'Graphische Sammlung'
  end

  def credits
    record.xpath('.//rightsResource/creditLine/text()')
  end

  def record_object_id_count
    if (count = record.xpath('.//ancestor::administrativeMetadata/resourceWrap/resourceSet').size) > 1
      count
    end
  end
end
