class Pandora::Indexing::Parser::BerlinIkbFarbdias < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'row',
      record_node_query: 'contains(bearbeitungsstand, "Erfassungsstufe II")')
  end
end
