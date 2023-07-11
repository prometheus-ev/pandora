class Pandora::Indexing::Parser::RmnMuseeDorsay < Pandora::Indexing::Parser::Parents::Rmn
  def initialize(source)
    source[:kind] = Source::KINDS[:museum]

    super(
      source,
      record_array_keys_path: ['_source', 'images'],
      object_array_keys_path: ['hits', 'hits'])
  end
end
