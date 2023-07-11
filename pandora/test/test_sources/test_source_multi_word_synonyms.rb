class TestSourceMultiWordSynonyms < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: 'row'
    )
  end
end
