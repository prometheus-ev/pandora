class Pandora::Indexing::Parser::AmsterdamMuseum < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      object_node_name: "record",
      record_node_name: "reproduction")
  end
end
