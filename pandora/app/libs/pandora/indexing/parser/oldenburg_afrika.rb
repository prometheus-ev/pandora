class Pandora::Indexing::Parser::OldenburgAfrika < Pandora::Indexing::Parser::Dilps
  def initialize(source, filename: nil)
    source[:kind] = Source::KINDS[:institutional]
    super(
      source,
      filename: filename,
      name: 'row'
    )
  end

  def path
    path_for('oldenburg_uni_afrika')
  end
end
