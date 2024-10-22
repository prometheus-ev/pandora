class Pandora::Indexing::Parser::CmaRecord < Pandora::Indexing::Parser::Record
  def record_id
    record['id'].to_s
  end

  def path
    if url = record.dig("images", "print", "url")
      url.gsub("https://openaccess-cdn.clevelandart.org/", "")
    end
  end

  def artist
    if record['creators'].size > 0
      record['creators'].map do |creator|
        creator['description']
      end
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

  def date_range
    if (from = record['creation_date_earliest']) &&
       (to = record['creation_date_latest']) &&
       (from <= to)
      @date_parser.date_range("#{from} - #{to}")
    end
  end

  def credits
    "The Cleveland Museum of Art  - #{record['creditline']}"
  end

  def rights_work
    record['copyright']
  end

  def rights_reproduction
    'CC0 1.0 Universal (CC0 1.0),https://creativecommons.org/publicdomain/zero/1.0/'
  end

  # def source_url
  #   n = record['accession_number']
  #   return if n.blank?

  #   "https://www.clevelandart.org/art/#{n}"
  # end

  def source_url
    record['url']
  end

  def culture
    record['culture']
  end

  def technique
    record['technique']
  end

  def material
    if record['support_materials']
      record['support_materials'].map do |support_material|
        support_material['description']
      end
    end
  end

  def department
    record['department']
  end

  def collection
    record['collection']
  end

  def genre
    record['type']
  end

  def size
    record['measurements']
  end

  def inscription
    if record['inscriptions']
      record['inscriptions'].map {|inscription|
        inscription['inscription']
      }
    end
  end

  def description
    record['digital_description']
  end

  def provenance
    if record['provenance']
      record['provenance'].map do |inscription|
        provenance = "#{inscription['description']}"
        provenance << " (#{inscription['date']})" if inscription['date']
        provenance
      end
    end
  end

  def discoveryplace
    record['find_spot']
  end

  def comment
    record['fun_fact']
  end
end
