class Pandora::Indexing::Parser::Parents::Erlangen < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    super(
      source,
      record_node_name: 'ROW')
  end
end
