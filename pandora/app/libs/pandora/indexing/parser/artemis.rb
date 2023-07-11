class Pandora::Indexing::Parser::Artemis < Pandora::Indexing::Parser::Parents::Artemis
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'datensatz',
      record_node_query: 'not(contains(bemerkung, "Bayerische Kunstgeschichte"))')
  end
end
