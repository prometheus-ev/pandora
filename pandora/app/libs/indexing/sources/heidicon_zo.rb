class Indexing::Sources::HeidiconZo < Indexing::Sources::Parents::Heidicon
  def records
    Indexing::XmlReaderNodeSet.new(document, "lido:lido", './/administrativeMetadata/resourceWrap/resourceSet')
  end
end
