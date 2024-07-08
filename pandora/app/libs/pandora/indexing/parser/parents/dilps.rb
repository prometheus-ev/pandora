class Pandora::Indexing::Parser::Parents::Dilps < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    super(
      source,
      record_node_name: "row")
  end
end
