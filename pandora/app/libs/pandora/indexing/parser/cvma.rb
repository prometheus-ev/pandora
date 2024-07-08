class Pandora::Indexing::Parser::Cvma < Pandora::Indexing::Parser::JsonReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(source)
  end
end
