class Pandora::Indexing::Parser::GiessenKup < Pandora::Indexing::Parser::Parents::Filemaker
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source)
  end
end
