class Pandora::Indexing::Parser::Mka < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    super(
      source,
      record_node_name: 'lido:lido',
      namespaces: true,
      namespace_uri: 'http://www.lido-schema.org'
    )
  end
end
