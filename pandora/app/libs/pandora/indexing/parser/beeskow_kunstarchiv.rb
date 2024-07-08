class Pandora::Indexing::Parser::BeeskowKunstarchiv < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    super(
      source,
      record_node_name: "row"
    )
  end
end
