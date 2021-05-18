require 'active_support/core_ext/uri'

class PMParser < URI::Parser
  def unescape(str)
    Addressable::URI.unescape(str)
  end
end

module URI
  def self.parser
    PMParser.new
  end
end
