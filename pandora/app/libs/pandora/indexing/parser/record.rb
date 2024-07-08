class Pandora::Indexing::Parser::Record
  def initialize(
    name:,
    record:,
    object:,
    record_object_id_count: {},
    parser: {},
    mapping:
  )

    @name = name
    @record = record
    @object = object
    @record_object_id_count = record_object_id_count

    @artist_parser = parser[:artist_parser]
    @date_parser = parser[:date_parser]
    @vgbk_parser = parser[:vgbk_parser]
    @warburg_parser = parser[:warburg_parser]
    @artigo_parser = parser[:artigo_parser]
    @miro_parser = parser[:miro_parser]

    @mapping = mapping
  end

  protected

    def generate_record_id(record_id)
      [name, Digest::SHA1.hexdigest(record_id)].join('-')
    end

    def rights_work
      if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
        @vgbk_parser.rights_work_vgbk
      end
    end

  private

    attr_reader :name
    attr_reader :record
    attr_reader :object
end
