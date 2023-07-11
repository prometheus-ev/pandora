class Pandora::Indexing::Parser::Parents::Artemis < Pandora::Indexing::Parser::XmlReader
  def initialize(source, record_node_name:, record_node_query:)
    super(
      source,
      record_node_name: record_node_name,
      record_node_query: record_node_query)
  end

  def preprocess
    puts "#{@source[:name]}: loading ArtigoParser..."
    @artigo_parser =  Pandora::Indexing::Parser::ArtigoParser.new(@source[:name])
    puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser =  Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
