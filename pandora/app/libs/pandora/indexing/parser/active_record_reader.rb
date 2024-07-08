class Pandora::Indexing::Parser::ActiveRecordReader < Pandora::Indexing::Parser
  def preprocess
    @record_count = scope.count
    @object_count = 0
  end

  def to_enum
    scope.find_each.map do |record|
      record_class = new_record(record)

      document(record_class)
    end
  end

  def scope
    @scope ||= Source.find_by(name: @source[:name]).uploads
  end

  def total
    to_enum.count
  end

  def batch
    'ActiveRecord'
  end

  private

    def new_record(record)
      "Pandora::Indexing::Parser::InstitutionalDatabaseRecord".constantize.new(
        name: @source[:name],
        record: record,
        object: nil,
        parser: {artist_parser: @artist_parser,
                 date_parser: @date_parser,
                 vgbk_parser: @vgbk_parser,
                 warburg_parser: @warburg_parser,
                 artigo_parser: @artigo_parser,
                 miro_parser: @miro_parser},
        mapping: nil
      )
    end
end
