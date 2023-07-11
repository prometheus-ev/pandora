class Pandora::Indexing::Parser::Cma < Pandora::Indexing::Parser::JsonReader
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(source)
  end
end
