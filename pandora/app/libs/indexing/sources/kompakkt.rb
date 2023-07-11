class Indexing::Sources::Kompakkt < Indexing::SourceSuper
  def document
    offset = 0
    results = []
    while (r = fetch_records(offset)).size > 0
      offset += r.size
      results += r
    end
    results
    
    @document = Indexing::JsonSource.new results

    results
  end

  def records
    document
  end

  def record_id
    record['_id']
  end

  def title
    record['name']
  end

  def artist
  end

  def person
    return unless record['creator']

    record['creator']['fullname']
  end

  def description
    record['relatedDigitalEntity']['description']
  end

  def path
    record['settings']['preview']
  end

  def iframe_url
    "https://kompakkt.de/viewer/index.html?entity=#{record_id}&mode=open"
  end

  def rights_work
    "CC #{record['relatedDigitalEntity']['licence']} (siehe <a href='https://kompakkt.de/entity/#{record_id}' target='_blank'>Kompakkt Objektseite</a>)"
  end

  def source_url
    "https://kompakkt.de/entity/#{record_id}"
  end


  protected

    def fetch_records(offset = 0)
      puts offset
      headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
      body = {
        "searchEntity" => true,
        "searchText" => "",
        "types" => ["model", "audio", "video", "image"],
        "filters" => {
          "annotated" => false,
          "annotatable" => false,
          "restricted" => false,
          "associated" => false
        },
        "offset" => offset
      }
      response = Faraday.post(
        'https://kompakkt.de/server/api/v1/post/explore',
        JSON.dump(body),
        headers
      )
      JSON.parse(response.body)
    end

end
