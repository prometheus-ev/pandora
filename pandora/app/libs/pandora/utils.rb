module Pandora::Utils
  def self.quarter_for(date)
    q = (date.month / 3.0).ceil
    "#{date.year}/#{q}"
  end
end
