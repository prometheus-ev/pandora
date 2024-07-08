class Pandora::Indexing::FieldValidator
  BOOLEAN = true
  attr_reader :validated_fields

  def run(processed_fields:)
    @processed_fields = processed_fields
    @validated_fields = {}

    @processed_fields.each do |key, value|
      if key == 'date_range' && value
        validate('date_range_from', value.from_time)
        validate('date_range_to', value.to_time)
        validate(key, {'gte' => value.from_time, 'lt' => value.to_time})
      else
        validate(key, value)
      end
    end

    @validated_fields
  end

  def validate(key, value = nil)
    validated_value = case key
    when 'artist_nested', 'title_nested', 'location_nested', 'credits_nested', 'rights_reproduction_nested', 'person_nested', 'authority_files'
      validated_value = validate_or_default(key, value, Array, [])
      validate_nested_field(key, validated_value)
    when 'artist_normalized'
      validate_or_default(key, value, Array, [])
    when 'date_range_from', 'date_range_to'
      validate_or_default(key, value, Time, nil)
    when 'rating_count', 'comment_count', 'record_object_id_count'
      validate_or_default(key, value, Integer, 0)
    when 'rating_average'
      validate_or_default(key, value, Float, 0.0)
    when 'user_comments'
      validate_or_default(key, value, String, '')
    when 'path'
      value = validate_or_default(key, value, String, nil)
      regex = /\A[\/]/

      if regex.match?(value)
        message = "The #{key} '#{value}' does not match " +
          "the regular expression '#{regex}'. " +
          "There must not be a '/' at the beginning of the #{key}."
        raise Pandora::Exception, message
      else
        value
      end
    when 'image_vector'
      validate_or_default(key, value, Array, nil)
    when 'is_main_record'
      validate_or_default(key, value, String, nil)
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
      if (value && type == BOOLEAN && (value.is_a?(TrueClass) || value.is_a?(FalseClass))) ||
         (value && value.is_a?(type))
        value
      elsif !value && (default || default.nil?)
        default
      else
        message = "The value '#{value}' is not allowed for field '#{key}'. " +
                  "It should be of type #{type}. The default value is '#{default}'."
        raise Pandora::Exception, message
      end
    end

    def validate_nested_field(name, nested_values)
      type = String
      default = nil

      nested_values.each do |nested_value|
        nested_value.each do |key, value|
          value_message = "The value '#{value}' is not allowed for field #{name}['#{key}']. " +
                          "It should be of type #{type}. The default value is '#{default}'."
          key_message = "The key '#{key}' is not allowed for field #{name}. " +
                        "If you need this key, please update the implementation."

          string_fields = [
            'name', 'label', 'id', 'dating', 'wikidata', 'license',
            'license_url', 'link_text', 'link_url', 'gnd_url'
          ]

          if string_fields.include?(key)
            if !value || value.is_a?(type)
              true
            else
              raise Pandora::Exception, value_message
            end
          else
            raise Pandora::Exception, key_message
          end
        end
      end
    end
end
