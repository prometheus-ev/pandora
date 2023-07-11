class Pandora::Indexing::Parser::DdorfKa < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'bilder')
  end
end

