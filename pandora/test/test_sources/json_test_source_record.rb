class JsonTestSourceRecord < Pandora::Indexing::Parser::Record
  def record_id
    record['id'].to_s
  end

  def artist
    if record['creators'].size > 0
      record['creators'].map { |creator|
        creator['description']
      }
    end
  end

  def title
    record['title']
  end

  def location
    current_location = record['current_location']

    location = "The Cleveland Museum of Art, Cleveland, Ohio"
    location << ", #{current_location},https://www.clevelandart.org/art/collection/search?filter-gallery=#{current_location}" if current_location

    location
  end

  def date
    record['creation_date']
  end
end
