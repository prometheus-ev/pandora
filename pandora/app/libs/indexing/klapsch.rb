class Indexing::Klapsch
  def initialize(attrs = {})
    @attrs = attrs
  end

  def match?(value = nil)
    value ||= @attrs

    return false if value.blank?

    case value
    when Array
      value.each do |e|
        return true if match?(e)
      end

      false
    when Hash
      value.each do |k, v|
        return true if match?(k)
        return true if match?(v)
      end

      false
    when String
      !!value.match?(/klapsch/i)
    else
      false
    end
  end
end
