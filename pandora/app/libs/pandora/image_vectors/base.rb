class Pandora::ImageVectors::Base
  attr_reader :count

  def initialize
    @count = 0
  end

  def self.id
    class_name.underscore
  end

  def generate(pids)
    results = {}

    pids.each do |pid|
      results[pid] = run(pid)
    end

    results
  end
end
