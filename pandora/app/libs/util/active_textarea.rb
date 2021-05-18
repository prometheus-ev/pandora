module Util
  module ActiveTextarea
    module ClassMethods
      def from_textarea(value, uniq = false, &block)
        value = value.split(TEXTAREA_SEPARATOR_RE) if value.is_a?(String)
        value = value.reject(&:blank?)
        value.uniq! if uniq

        if block
          # There is only one call to this method with a block (proc, actually):
          # accounts_controller.rb:129
          value.each do |v|
            account = Account.find_by!(login: v)
            block[account, v]
          end
        else
          if self == Keyword
            value.map do |v|
              Keyword.ensure(v)
            end.compact
          else
            raise Pandora::Exception, "invalid object: #{self.inspect}"
          end
        end
      end
    end

    
    protected
    
      def from_textarea(value)
        value.is_a?(String) ? value.split(TEXTAREA_SEPARATOR_RE).reject(&:blank?) : value
      end

    
    private
    
      def self.included(base)
        base.extend(ClassMethods)
      end

  end
end
