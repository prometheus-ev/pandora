class Pandora::Indexing::Parser::JsonReader < Pandora::Indexing::Parser
  def initialize(
    source,
    filenames: nil,
    record_array_keys_path: nil,
    object_array_keys_path: nil)

    super(source)

    @filenames = filenames || default_filenames
    @record_array_keys_path = record_array_keys_path
    @object_array_keys_path = object_array_keys_path

    @object_count = 0
    @record_count = 0
  end

  attr_writer :filename

  def read
    @json = JSON.load_file(@filename)
  end

  def preprocess
    read

    if has_objects?
      preprocess_objects
    else
      @record_count = if @record_array_keys_path
        @json.dig(*@record_array_keys_path).size
      else
        @json.size
      end

      @object_count = @record_count
    end
  end

  def preprocess_objects
    @record_object_id_count = {}
    @object_count = 0
    @record_count = 0

    if @object_array_keys_path
      enumerator = @json.dig(*@object_array_keys_path).lazy
    else
      enumerator = @json.lazy
    end

    enumerator = enumerator.each do |object|
      @object = object

      @object_count += 1

      object.dig(*@record_array_keys_path).map do |record|
        record_class = new_record(record)
        r_object_id = record_class.record_object_id

        unless r_object_id.blank?
          if @record_object_id_count.has_key?(r_object_id)
            @record_object_id_count[r_object_id] += 1
          else
            @record_object_id_count[r_object_id] = 1
          end
        end

        @record_count += 1

        printf "#{@source[:name]}: #{@object_count} objects with #{@record_count} records preprocessed".ljust(60) + "\r"
      end
    end

    puts
  end

  def to_enum
    if @object_array_keys_path
      enumerator = @json.dig(*@object_array_keys_path).lazy

      enumerator = enumerator.map do |object|
        @object = object

        object.dig(*@record_array_keys_path).map do |record|
          record_class = new_record(record)

          document(record_class)
        end
      end

      enumerator.flat_map { |i| i.each.lazy }
    else
      if @record_array_keys_path
        enumerator = @json.dig(*@record_array_keys_path).lazy

        enumerator.map do |record|
          record_class = new_record(record)

          document(record_class)
        end
      else
        enumerator = @json.lazy

        enumerator.map do |record|
          record_class = new_record(record)

          document(record_class)
        end
      end
    end
  end

  protected

  def default_filenames
    directory = "#{ENV['PM_DUMPS_DIR']}#{self.class.name.demodulize.underscore}"
    filename = "#{directory}.json"

    if File.exist?(filename) 
      [filename]
    elsif File.directory?(directory)
      children = Dir["#{directory}/*"]
      puts "#{@source[:name]}: #{children.count} dump files"
      children
    end
  end

  private

  def new_record(record)
    @record_class_name.constantize.new(
      name: @source[:name],
      record: record,
      object: @object,
      record_object_id_count: @record_object_id_count,
      artist_parser: @artist_parser,
      date_parser: @date_parser,
      vgbk_parser: @vgbk_parser,
      warburg_parser: @warburg_parser,
      artigo_parser: @artigo_parser,
      miro_parser: @miro_parser)
  end
end
