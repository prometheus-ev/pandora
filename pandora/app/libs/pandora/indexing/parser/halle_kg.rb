class Pandora::Indexing::Parser::HalleKg < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "table",
          record_node_query: "boolean(self::node()[column[@name='quelle'][text()!='' and text()!=' ']])")
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
