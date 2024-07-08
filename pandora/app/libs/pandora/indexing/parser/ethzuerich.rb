class Pandora::Indexing::Parser::Ethzuerich < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "dokument")
  end
end
