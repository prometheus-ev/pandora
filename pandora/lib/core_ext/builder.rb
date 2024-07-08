require 'builder/xmlmarkup'
require 'builder/blankslate'

module Builder
  class XmlBase < BlankSlate
    # Append _indented_ +text+ to the output target.
    def itext!(text)
      text.split($/).each{|t| _indent; text!(t); _newline}
    end
  end
end
