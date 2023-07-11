class Pandora::Indexing::Parser::ArtemisBk < Pandora::Indexing::Parser::Parents::Artemis
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(
      source,
      record_node_name: 'datensatz',
      record_node_query: 'contains(bemerkung, "Bayerische Kunstgeschichte")')
  end
end
