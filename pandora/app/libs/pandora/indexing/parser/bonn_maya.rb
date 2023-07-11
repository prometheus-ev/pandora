class Pandora::Indexing::Parser::BonnMaya < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:research]

    super(source,
      name: 'medium')
  end
end
