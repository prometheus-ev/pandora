class Pandora::Indexing::Parser::InstitutionalDatabaseRecord < Pandora::Indexing::Parser::Record
  def record_id
    if record.index_record_id.blank?
      record.id.to_s
    else
      record.index_record_id
    end
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "#{ENV['PM_BASE_URL']}/api/blob/image/original/#{record.image_id}"
  end

  def artist
    record.artist
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    @artist_normalized = @artist_parser.normalize([artist])
  end

  def title
    record.title
  end

  def resource_title
    record.resource_title
  end

  def location
    record.location
  end

  def latitude
    record.latitude
  end

  def longitude
    record.longitude
  end

  def discoveryplace
    record.discoveryplace
  end

  def genre
    record.genre
  end

  def material
    record.material
  end

  def description
    record.description
  end

  def credits
    record.credits
  end

  def rights_work
    record.rights_work
  end

  def rights_reproduction
    record.rights_reproduction
  end

  def addition
    record.addition
  end

  def annotation
    record.annotation
  end

  def iconography
    record.iconography
  end

  def institution
    record.institution
  end

  def inventory_no
    record.inventory_no
  end

  def origin
    record.origin
  end

  def other_persons
    record.other_persons
  end

  def photographer
    record.photographer
  end

  def size
    record.size
  end

  def subtitle
    record.subtitle
  end

  def text
    record.text
  end

  def license
    record.license
  end

  def isbn
    record.isbn
  end

  def keyword
    record.keyword
  end

  def technique
    record.technique
  end

  def epoch
    record.epoch
  end

  def signature
    record.signature
  end

  def date
    record.date
  end

  def date_range
    return @date_range if @date_range

    @date_range = @date_parser.date_range(date)
  end

  def keywords
    record.keywords.to_a.map{|keyword| keyword.title} if record.keywords.count > 0
  end
end
