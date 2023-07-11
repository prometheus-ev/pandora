class Pandora::Indexing::Parser::FfmConedakor < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: 'work',
      record_node_query: 'mediums/medium'
    )
  end

  def preprocess
    puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser =  Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
