class Pandora::Indexing::Parser::JsonReader < Pandora::Indexing::Parser
  def initialize(
    source,
    record_array_keys_path: nil,
    object_array_keys_path: nil
  )

    super(source)

    @record_array_keys_path = record_array_keys_path
    @object_array_keys_path = object_array_keys_path

    @object_count = 0
    @record_count = 0
  end

  attr_writer :filename

  def preprocess
    if has_objects?
      preprocess_objects
    else
      @record_count = reader.count
      @object_count = @record_count
    end
  end

  def preprocess_objects
    @record_object_id_count = {}
    @object_count = 0
    @record_count = 0

    enumerator = reader

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

        Pandora.printf "#{@source[:name]}: #{@object_count} objects with #{@record_count} records preprocessed".ljust(60) + "\r"
      end
    end

    Pandora.puts
  end

  def to_enum
    enumerator = reader

    if @object_array_keys_path
      enumerator = enumerator.map do |object|
        @object = object

        object.dig(*@record_array_keys_path).map do |record|
          record_class = new_record(record)

          document(record_class)
        end
      end

      enumerator.flat_map{|i| i.each.lazy}
    else
      enumerator.map do |record|
        record_class = new_record(record)

        document(record_class)
      end
    end
  end


  private

    def reader
      filenames.to_enum.lazy.flat_map do |filename|
        @batch = File.basename(filename)

        json = JSON.load_file(filename)

        if @record_array_keys_path
          json.dig(*@record_array_keys_path).lazy
        else
          if json.is_a?(Hash)
            Array.wrap(json).lazy
          else
            json.lazy
          end
        end
      end
    end

    def new_record(record)
      @record_class_name.constantize.new(
        name: @source[:name],
        record: record,
        object: @object,
        record_object_id_count: @record_object_id_count,
        parser: {artist_parser: @artist_parser,
                 date_parser: @date_parser,
                 vgbk_parser: @vgbk_parser,
                 warburg_parser: @warburg_parser,
                 artigo_parser: @artigo_parser,
                 miro_parser: @miro_parser},
        mapping: @mapping
      )
    end

    def filenames
      directory = "#{ENV['PM_DUMPS_DIR']}#{self.class.name.demodulize.underscore}"
      filename = "#{directory}.json"

      if File.exist?(filename)
        [filename]
      elsif File.directory?(directory)
        children = Dir["#{directory}/*"]
        Pandora.puts "#{@source[:name]}: #{children.count} dump files"
        children
      end
    end
end
