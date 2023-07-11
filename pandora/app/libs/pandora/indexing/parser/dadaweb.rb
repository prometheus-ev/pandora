class Pandora::Indexing::Parser::Dadaweb < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'ROW',
    )
  end

  def preprocess
    puts "#{@source[:name]}: loading ArtigoParser..."
    @artigo_parser =  Pandora::Indexing::Parser::ArtigoParser.new(@source[:name])
    puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser =  Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
