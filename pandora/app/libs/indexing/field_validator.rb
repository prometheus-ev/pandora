class Indexing::FieldValidator
  attr_reader :validated_fields

  def initialize(processed_fields: nil)
    @processed_fields = processed_fields
    @validated_fields = {}
  end

  def run
    @processed_fields.each do |key, value|
      if key == 'date_range' && value
        validate(key, {'gte' => value.from_time, 'lt' => value.to_time})
        validate('date_range_from', value.from_time)
        validate('date_range_to', value.to_time)
      else
        validate(key, value)
      end
    end

    @validated_fields
  end

  def validate(key, value = nil)
    validated_value = case key
                      when 'artist_normalized'
                        validate_or_default(key, value, Array, [])
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
                        regex = /\A[\/]/

                        if regex.match?(value)
                          message = "The #{key} '#{value}' does not match the regular expression '#{regex}'. " +
                                    "There must not be a '/' at the beginning of the #{key}."
                          raise Pandora::Exception, message
                        else
                          value
                        end
                      when 'image_vector'
                        validate_or_default(key, value, Array, nil)
                      else
                        value
                      end

    if !validated_value.nil?
      @validated_fields.merge!({key => validated_value})
    end

    validated_value
  end

  private

  def validate_or_default(key, value, type, default)
    if value && value.is_a?(type)
      value
    elsif !value && (default || default.nil?)
      default
    else
      message = "The value '#{value}' is not allowed for field '#{key}'. " +
                "It should be of type #{type}. The default value is '#{default}'."
      raise Pandora::Exception, message
    end
  end
end
