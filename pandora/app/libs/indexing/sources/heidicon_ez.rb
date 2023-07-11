class Indexing::Sources::HeidiconEz < Indexing::Sources::Parents::Heidicon
  def pool_name
    'Eva Zippel'
  end

  def record_object_id_count
    if (count = record.xpath('.//ancestor::administrativeMetadata/resourceWrap/resourceSet').size) > 1
      count
    end
  end
end
