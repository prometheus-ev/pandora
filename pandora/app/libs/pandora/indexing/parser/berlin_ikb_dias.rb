class Pandora::Indexing::Parser::BerlinIkbDias < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'result')
  end
end
