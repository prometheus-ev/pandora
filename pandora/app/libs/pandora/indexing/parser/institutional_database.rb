class Pandora::Indexing::Parser::InstitutionalDatabase < Pandora::Indexing::Parser::ActiveRecordReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]
    source[:type] = "upload"

    super(source)
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
