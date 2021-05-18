# Parent class for all sources. Acts like an interface and common method provider.
#
# Required source fields could all be add here, like artist, title, etc. Add them to you liking.
class Indexing::SourceInterface < Indexing::SourceParent
  def records
    raise NotImplementedError, "#{self.class}##{__method__} method must be implemented."
  end

  def record_id
    raise NotImplementedError, "#{self.class}##{__method__} method must be implemented."
  end

  def path
    raise NotImplementedError, "#{self.class}##{__method__} method must be implemented."
  end
end
