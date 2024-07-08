class Pandora::Indexing::Parser::EichstaettUb < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: "item")
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
