class Pandora::Indexing::Parser::Albertina < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: 'record',
      namespaces: true,
      namespace_uri: 'http://www.openarchives.org/OAI/2.0/'
    )
  end
end
