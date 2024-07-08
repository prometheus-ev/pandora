class Pandora::Indexing::Parser::Daumier < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(
      source,
      object_node_name: "row",
      record_node_name: "sammlungen",
      record_node_query: "boolean(Abbildung[text() = '1'])")
  end
end
