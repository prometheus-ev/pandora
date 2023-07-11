class Pandora::Indexing::Parser::Caerlangen < Pandora::Indexing::Parser::Parents::Erlangen
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(source)
  end
end
