class Pandora::Indexing::Parser::GoettingenArch < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "ROW")
  end
end
