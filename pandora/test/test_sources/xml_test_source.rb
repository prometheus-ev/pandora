class XmlTestSource < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(source,
          record_node_name: "row")
  end
end
