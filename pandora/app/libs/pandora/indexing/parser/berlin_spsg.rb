class Pandora::Indexing::Parser::BerlinSpsg < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_node_name: "museumdat:museumdat")
  end
end
