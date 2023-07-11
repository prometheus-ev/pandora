class Pandora::Indexing::Parser::Archgiessen < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'datensatz'
    )
  end
end
