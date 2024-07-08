class Pandora::Indexing::Parser::Parents::BerlinIkb < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "row")
  end
end
