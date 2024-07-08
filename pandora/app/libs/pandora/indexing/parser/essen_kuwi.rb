class Pandora::Indexing::Parser::EssenKuwi < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "Werk")
  end
end
