class Pandora::Indexing::Parser::BochumUg < Pandora::Indexing::Parser::Parents::Dilps
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(source)
  end
end
