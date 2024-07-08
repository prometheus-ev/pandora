class Indexing::Sources::HeidiconFb < Indexing::Sources::Parents::Heidicon
  def pool_name
    'UB Fliegende Blätter'
  end

  def source_url
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectWebResource[@label="Verweis"]/text()')
  end

  def external_references
    ""
  end
end
