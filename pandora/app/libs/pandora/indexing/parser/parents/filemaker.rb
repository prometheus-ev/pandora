class Pandora::Indexing::Parser::Parents::Filemaker < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    super(source,
          record_node_name: "datensatz")
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
