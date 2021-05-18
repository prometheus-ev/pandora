class Indexing::JsonSource
  def initialize(document)
    @document = document
    @errors =  []

    begin
      @records = JSON.parse(document)
    rescue JSON::ParserError => e
      @errors = [e.message]
    end
  end

  def records
    @records
  end

  def errors
    @errors
  end

  def each
    @records.each do |record|
      yield record
    end
  end
end
