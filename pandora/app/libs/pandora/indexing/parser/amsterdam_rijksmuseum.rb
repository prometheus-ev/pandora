# https://data.rijksmuseum.nl/object-metadata/download/
class Pandora::Indexing::Parser::AmsterdamRijksmuseum < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: "ArtObject",
      record_node_query: "boolean(WebImage)")
  end
end
