class Pandora::Indexing::Parser::BochumKgi < Pandora::Indexing::Parser::Parents::Dilps
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source)
  end
end
