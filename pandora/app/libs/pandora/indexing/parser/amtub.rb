class Pandora::Indexing::Parser::Amtub < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: 'datensatz'
    )
  end
end
