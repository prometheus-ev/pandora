class Pandora::Indexing::Parser::Desanhalt < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "Werk")
  end
end
