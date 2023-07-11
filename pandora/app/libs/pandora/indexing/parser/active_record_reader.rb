class Pandora::Indexing::Parser::ActiveRecordReader < Pandora::Indexing::Parser
  def initialize(source, filename: nil)
    super(source)
  end

  def preprocess
    @record_count = scope.count
  end

  def to_enum
    scope.find_each.map do |record|
      record_class = new_record(record)

      document(record_class)
    end
  end

  def scope
    @scope ||= Source.find_by(name: source.name).uploads
  end

  private

  def new_record(record)
    @record_class_name.constantize.new(
      name: @source[:name],
      record: record,
      artist_parser: @artist_parser,
      date_parser: @date_parser,
      vgbk_parser: @vgbk_parser,
      warburg_parser: @warburg_parser)
  end
end
