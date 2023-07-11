class Pandora::Indexing::Parser
  def initialize(source)
    source[:type] = 'dump' if source[:type].blank?
    @source = source
    @record_class_name = "#{ENV['PM_PANDORA_INDEXING_PARSER_CLASS_NAME_PREFIX']}#{source[:name].camelize}Record"

    @field_processor = Pandora::Indexing::FieldProcessor.new
    @field_validator = Pandora::Indexing::FieldValidator.new
    @rights_work_artist_updater = Indexing::RightsWorkArtistUpdater.new

    puts "#{@source[:name]}: loading ArtistParser..."
    @artist_parser =  Pandora::Indexing::Parser::ArtistParser.new
    puts "#{@source[:name]}: loading DateParser..."
    @date_parser =  Pandora::Indexing::Parser::DateParser.new
    puts "#{@source[:name]}: loading VgbkParser..."
    @vgbk_parser =  Pandora::Indexing::Parser::VgbkParser.new
    puts "#{@source[:name]}: loading WarburgParser..."
    @warburg_parser =  Pandora::Indexing::Parser::WarburgParser.new
  end

  attr_reader :filenames
  attr_reader :source
  attr_accessor :object
  attr_reader :object_count
  attr_reader :record_count

  def document(record_class)
    processed = @field_processor.run(
      source: @source,
      record: record_class,
      field_keys: field_keys)
    validated = @field_validator.run(
      processed_fields: processed)
    validated = @rights_work_artist_updater.run(validated)

    validated
  end

  def has_objects?
    field_keys.include?('record_object_id')
  end

  protected

  def field_keys
    return @field_keys if @field_keys

    result = @record_class_name.constantize.public_instance_methods - @record_class_name.constantize.public_methods

    @field_keys = result.map{|e| e.to_s}.sort
  end
end
