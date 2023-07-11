class Pandora::Indexing::Parser::Bpk < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]
    records_to_exclude = %w[21466.jpg 21468.jpg 21469.jpg 21470.jpg 21471.jpg 21472.jpg 21473.jpg 21474.jpg 21475.jpg 23204.jpg 43884.jpg 43887.jpg 44005.jpg 44148.jpg 75689.jpg]

    super(
      source,
      record_node_name: 'PHOTO',
      record_node_query: 'not(contains(OBJECTTYPE, "Fotografie") and contains(INSTITUTION,             "Kunstbibliothek"))',
      records_to_exclude: records_to_exclude)
  end

  def preprocess
    puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser =  Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
