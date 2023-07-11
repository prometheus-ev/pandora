class Pandora::Indexing::Parser::Parents::Rmn < Pandora::Indexing::Parser::JsonReader
  def initialize(source, record_array_keys_path:, object_array_keys_path:)
    super(
      source,
      record_array_keys_path: record_array_keys_path,
      object_array_keys_path: object_array_keys_path)
  end
end
