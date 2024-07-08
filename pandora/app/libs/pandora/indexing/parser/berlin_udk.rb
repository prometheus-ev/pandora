class Pandora::Indexing::Parser::BerlinUdk < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: "objekt")
  end
end
