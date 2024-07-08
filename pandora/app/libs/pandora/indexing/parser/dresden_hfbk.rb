class Pandora::Indexing::Parser::DresdenHfbk < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source,
          record_node_name: "row")
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
