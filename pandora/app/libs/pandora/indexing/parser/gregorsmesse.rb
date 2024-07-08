class Pandora::Indexing::Parser::Gregorsmesse < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(source,
          record_node_name: "ROW")
  end
end
