class Pandora::Indexing::Parser::Amtub < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: 'lido:lido',
      namespaces: true,
      namespace_uri: 'http://www.lido-schema.org'
    )
  end
end
