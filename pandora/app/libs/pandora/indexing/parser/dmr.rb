class Pandora::Indexing::Parser::Dmr < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: "entry")
  end
end
