# https://data.rijksmuseum.nl/object-metadata/download/
class Pandora::Indexing::Parser::AmsterdamRijksmuseum < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: 'lido:lido',
      record_node_query: "boolean(./lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:rightsType/lido:term[text()='Public Domain Mark 1.0'])",
      namespaces: true,
      namespace_uri: 'http://www.lido-schema.org'
    )
  end
end
