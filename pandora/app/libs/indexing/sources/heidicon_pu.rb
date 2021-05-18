class Indexing::Sources::HeidiconPu < Indexing::Sources::Parents::Heidicon
  def pool_name
    'UB Britische Karikaturen'
  end

  def source_url
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectWebResource[@label="Verweis"]/text()')
  end

  def external_references
    ""
  end

end
