class Indexing::Sources::HeidiconUa < Indexing::Sources::Parents::Heidicon
  def pool_name
    'UA Bildarchiv - Studentenlokal "Zum Roten Ochsen"'
  end

  def date
  end

  def record_object_id_count
    if (count = record.xpath('.//ancestor::administrativeMetadata/resourceWrap/resourceSet').size) > 1
      count
    end
  end
end
