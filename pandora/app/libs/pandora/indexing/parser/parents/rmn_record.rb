class Pandora::Indexing::Parser::Parents::RmnRecord < Pandora::Indexing::Parser::Record
  def record_id
    generate_record_id(record_id_value)
  end

  def main_record_id
    if object.dig('_source', 'images')
      generate_record_id(main_record_id_value)
    end
  end

  def is_main_record
    (record_id == main_record_id).to_s
  end

  def record_object_id
    if !record_object_id_value.blank?
      generate_record_id(record_object_id_value)
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def path
    record['urls']['original'].delete_prefix('https://api.art.rmngp.fr/')
  end

  def source_url
    n = object['_source']['accession_number']
    return if n.blank?
    "http://www.photo.rmn.fr/archive/#{n}.html"
  end

  def artist
    authors = object['_source']['authors']
    authors[0]['name']['en'] unless authors.blank?
  end

  def title
    if object['_source']['title']
      object['_source']['title']['fr']
    end
  end

  def location
    if object['_source']['location']
      object['_source']['location']['name']['fr']
    end
  end

  def date
    if object['_source']['date']
      object['_source']['date']['display']
    end
  end

  def date_range
    if date
      @date_parser.date_range(date)
    end
  end

  def credits
    if object.dig('_source', 'image', 'source')
      object['_source']['image']['source']['copyright']
    end
  end

  def rights_work
    object['_source']['copyright']
  end

  def rights_reproduction
    if object.dig('_source', 'image', 'photographer')
      object['_source']['image']['photographer']['name']  
    end
  end

  def source_url
    if object['_source']['image']
      object['_source']['image']['permalink']
    end
  end

  def culture
    object['_source']['culture']
  end

  def technique 
    if object['_source']['techniques']
      object['_source']['techniques'].map { |technique|
        technique['suggest_en']['input']
      }  
    end
  end

  def material
    if object['_source']['support_materials']
      object['_source']['support_materials'].map { |support_material|
        support_material['description']
      }
    end
  end

  def department
    object['_source']['department']
  end

  def collection
    if object['_source']['collections']
      object['_source']['collections'].map { |collection|
        collection['name']['fr']
      }
    end
  end

  def genre
    object['_source']['type']
  end

  def size
    width = object['_source']['width']
    height = object['_source']['height']

    if width.blank? && height.blank?
      nil
    elsif height.blank?
      "#{width} mm"
    elsif width.blank?
      "#{height} mm"
    else
      "#{height} mm x #{width} mm"
    end
  end

  def description
    if object['_source']['detail']
      object['_source']['detail']['fr']
    end
  end

  def pictured_location
    if object['_source']['geographies'] 
      object['_source']['geographies'].map { |geography|
      geography['name']['fr']
    }
    end
  end

  def epoch
    if object['_source']['periods']
      object['_source']['periods'].map { |period|
        period['suggest_en']['input']
      }
    end
  end

  def keywords
    keywords = []

    if object.dig('_source', 'keywords')
      object['_source']['keywords'].each do |keyword|
        if keyword.dig('name', 'fr')
          keywords << keyword['name']['fr']
        end

        if keyword.dig('name', 'en')
          keywords << keyword['name']['en']
        end
      end
    end

    if record.dig('keywords')
      record['keywords'].each do |keyword|
        if keyword.dig('name', 'fr')
          keywords << keyword['name']['fr']
        end

        if keyword.dig('name', 'en')
          keywords << keyword['name']['en']
        end
      end
    end

    keywords.uniq
  end

  def record_identifier
    record.dig('identifier')
  end

  private

  def record_id_value
    if record_object_id_value.blank?
      record['id'].to_s
    else
      "#{record_object_id_value}#{record['id'].to_s}"
    end
  end

  def main_record_id_value
    if record_object_id_value.blank?
      object['_source']['images'][0]['id'].to_s
    else
      "#{record_object_id_value}#{object['_source']['images'][0]['id'].to_s}"
    end
  end

  def record_object_id_value
    object['_source']['id'].to_s
  end
end
