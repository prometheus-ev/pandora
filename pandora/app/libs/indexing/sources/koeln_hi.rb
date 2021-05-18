class Indexing::Sources::KoelnHi < Indexing::SourceSuper

  # StatementID "EqSriBebHxRZwvRv" == prometheus-freigabe
  def records
    document.xpath("//item[./metadataSet/metadata/statement[text()='#{url('EqSriBebHxRZwvRv')}']/../text[text()='ja']]")
  end

  def record_id
    record.xpath('@id').to_s.gsub(/http:\/\/134.95.11.135\/imeji\/item\//, '')
  end

  def url(statement_id)
    "http://134.95.11.135/imeji/statement/#{statement_id}"
  end

  def metadata(element, statement_id)
    record.xpath(".//metadataSet/metadata/statement[text()=\"#{url(statement_id)}\"]/../#{element}/text()")
  end

  def metadata_text(statement_id)
    metadata('text', statement_id)
  end

  def path
    record.at_xpath(".//fullImageUrl/text()").to_s.gsub(/http:\/\/134.95.11.135\/imeji\/file\//, '')
  end

  def artist
    metadata_text('VgaaHFFIm44ltwBq')
  end

  def title
    metadata_text('YtGxMqoygq0pgavs')
  end

  def credits
    metadata_text('DunYQUZPTZhVhuS')
  end

  def date
    metadata_text('sWzEwOGsvYg6hAy')
  end

  def format
    metadata_text('lsA7ccxdGBSaLLyy')
  end

  def picture_variation
    metadata_text('QloNpLBZSVMo2Wd5')
  end

  def institution
    metadata_text('_qvFOsI8IMyHXR1E')
  end

  def granted_by
    metadata_text('Wn1ItjCsU_hraPey')
  end

  def published_in
    metadata_text('h4iiyWDQK19WZ7A0')
  end

  def context_of_publication
    metadata_text('aP18jgHZwNZuHz')
  end

  def further_context_of_publication
    metadata_text('dDvjkZ8to883vAtO')
  end

  def publicationplace
    metadata_text('nAcXTDFmG12qD3LA')
  end

  def photoagency
    metadata_text('L4tMGN4ro3SGnu6')
  end

  def publisher
    metadata_text('LwuW2MVjVrfgiyM6')
  end

  def image_information
    metadata_text('I_NJkZ7AFg03a96e')
  end

  def artist_information
    metadata_text('Kp82N9e8D3gEVzX4')
  end

  def keyword_main_topic
    metadata_text('OEoDRApD6sMDwIA5')
  end

  def keyword_denotated_connotated_incidents_ontogenetics
    metadata_text('HIh5Z95w6QkEUaaM')
  end

  def keyword_collections
    metadata_text('zxkXo1uLK1THPFm')
  end

  def keyword_persons_beings_objects
    metadata_text('PXiaDq7ZM1Cz8leE')
  end

  def keyword_composition_proximity_persons_objects
    metadata_text('uXn7XUabckUSRPCQ')
  end

  def keyword_posture
    metadata_text('xAIXc3tMK6HxpdrP')
  end

  def keyword_gestics
    metadata_text('UD0ILoqcGVH2WCY')
  end

  def keyword_mimics
    metadata_text('ACLNoOFDDdstpbxk')
  end

  def keyword_gaze
    metadata_text('VvFVX23oTsJ8MQ1R')
  end

  def keyword_body_movement
    metadata_text('JTLuUwKkipI_0Nd')
  end

  def keyword_emotions
    metadata_text('ek5rA3K3f23hW8dv')
  end

  def photographed_location
    metadata_text('hHC02uLaLLloJ4Q1')
  end

  def location
    metadata_text('QC6xzFRiMHw3lfhn')
  end

  def person_of_interest
    metadata_text('ZBzVPnZRHwORW')
  end

  def material
    metadata_text('f8KDY8WH57xSY9l')
  end

  def technique
    metadata_text('w6DVmUUI1NPRw8J')
  end

  def shot_composition
    metadata_text('s3rox6Ilm8MyqM9v')
  end

  def portrait
    metadata_text('jcoqXs0ylW764qnz')
  end

  def rights_reproduction
    metadata_text('CZ3CJ0HRs0XVQD3k')
  end

  def similar_pictures_collection
    metadata_text('IYETt3e0gZDhC6YT')
  end

end
