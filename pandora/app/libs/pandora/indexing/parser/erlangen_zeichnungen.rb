class Pandora::Indexing::Parser::ErlangenZeichnungen < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(
      source,
      record_node_name: "bvb")
  end
end
