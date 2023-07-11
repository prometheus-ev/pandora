class Pandora::Indexing::Parser::Bern < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'row',
      record_node_query: 'Bilder/bild/text()')
  end

  def preprocess
    puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser =  Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
