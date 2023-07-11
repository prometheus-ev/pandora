class Indexing::Sources::HeidiconKg < Indexing::Sources::Parents::Heidicon
  def path
    return miro if miro?

    super
  end

  def pool_name
    'IEK Europäische Kunstgeschichte'
  end

  def record_object_id_count
    if (count = record.xpath('.//ancestor::administrativeMetadata/resourceWrap/resourceSet').size) > 1
      count
    end
  end
end
