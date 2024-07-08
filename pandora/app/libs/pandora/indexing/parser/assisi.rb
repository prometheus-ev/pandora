class Pandora::Indexing::Parser::Assisi < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(
      source,
      record_node_name: "dokument")
  end
end
