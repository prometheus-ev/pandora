class Indexing::FieldValidator
  attr_reader :fields

  def initialize(field_processor = nil, field_keys = nil)
    @field_processor = field_processor
    @field_keys = field_keys

    @fields = {}
  end

  def run
    @field_keys.each do |key|
      if @field_processor.respond_to?(key)
        value = @field_processor.send(key)
        case key
        when 'record_id'
          value = @field_processor.process_record_id(value)
          validate(key, value)
        when 'path'
          value = @field_processor.process_path(value)
          validate(key, value)
        when 'date_range'
          if value
            validate(key, {'gte' => value.from_time, 'lt' => value.to_time})
            validate('date_range_from', value.from_time)
            validate('date_range_to', value.to_time)
          end
        when 'rating_count', 'rating_average', 'comment_count', 'user_comments'
          validate(key, value)
        else
          validate(key, @field_processor.process_node_set(value))
        end
      end
    end

    @fields
  end

  def validate(key, value = nil)
    validated_value = case key
                      when 'date_range_from', 'date_range_to'
                        validate_or_default(key, value, Time, nil)
                      when 'rating_count', 'comment_count'
                        validate_or_default(key, value, Integer, 0)
                      when 'rating_average'
                        validate_or_default(key, value, Float, 0.0)
                      when 'user_comments'
                        validate_or_default(key, value, String, '')
                      when 'path'
                        value = validate_or_default(key, value, String, nil)
                        validate_path(key, value, /\A[\/]/)
                      else
                        value
                      end

    @fields.merge!({key => validated_value})

    validated_value
  end

  private

  def validate_or_default(key, value, type, default)
    if value && value.is_a?(type)
      value
    elsif !value && default
      default
    else
      raise Pandora::Exception, "The value '#{value}' is not allowed for field '#{key}'. It should be of type #{type}. The default value is '#{default}'."
    end
  end

  def validate_path(key, value, regex)
    if regex.match?(value)
      raise Pandora::Exception, "The #{key} '#{value}' does not match the regular expression '#{regex}'. There must not be a '/' at the beginning of the #{key}."
    else
      value
    end
  end
end
