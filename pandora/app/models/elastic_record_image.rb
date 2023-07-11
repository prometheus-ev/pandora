# Class representing an Elasticsearch record with pandora dependencies.
class ElasticRecordImage
  attr_accessor :id, :pid, :pobject_id, :artist, :artist_nested, :title, :location, :date,
    :credits, :rights_work, :rights_reproduction, :path, :rating, :votes,
    :source_id, :source, :elastic_record

  def initialize(id, elastic_record, super_image, elastic_record_source)
    @id = id
    @pid = id
    # Set Elasticsearch record metadata
    @elastic_record = elastic_record
    # Set required attributes
    # Object#object_id is reserved in newer ruby versions
    @pobject_id = elastic_record['_source']['record_object_id']
    @artist = elastic_record['_source']['artist']
    @artist_nested = elastic_record['_source']['artist_nested']
    @title = elastic_record['_source']['title']
    @location = elastic_record['_source']['location']
    @date = elastic_record['_source']['date']
    @credits = elastic_record['_source']['credits']
    @rights_work = elastic_record['_source']['rights_work']
    @rights_reproduction = elastic_record['_source']['rights_reproduction']
    @path = elastic_record['_source']['path']
    @rating = elastic_record['_source']['rating_average']
    @votes = elastic_record['_source']['rating_count']
    # @comments = Image[id].comments
    # @source_id = elastic_record_source.id
    @super_image = super_image
    @source = elastic_record_source
  end

  # we use this data if a pid can't be retrieved from elasticsearch
  def self.dummy_record
    return {
      '_source' => {
        'title' => 'image not found',
        'path' => 'not-available'
      }
    }
  end

  def super_image
    @super_image || Pandora::SuperImage.new(@pid, elastic_record_image: self)
  end

  def comments
    super_image.image.comments
  end

  def has_record?
    true
  end

  def elastic_record?
    true
  end

  def upload_record?
    false
  end

  def elastic_record_image
    self
  end

  def attrib(name)
    elastic_record['_source'][name]
  end

  def source_url
    source.url
  end

  def source_name
    source.name
  end

  def source_title
    source.title
  end

  def vgbk
    if rights_work
      rights_work.map { |right_work|
        if right_work == "rights_work_vgbk"
          return right_work
        else
          return ""
        end
      }
    else
      ""
    end
  end

  def associated_count(current_user)
    0
  end

  def filename(ext = nil)
    Image[id].filename(ext)
  end

  def to_txt(options = {})
    txt = []
    for field in Indexing::IndexFields.display do
      unless (value = elastic_record['_source'][field]).blank?
        # REWRITE: Array#to_s used to concat
        # txt << field.humanize.titleize.t + ": " + value.to_s
        v = if value.is_a?(String)
              value
            elsif value.is_a?(Integer)
              value.to_s
            else
              value.join
            end

        txt << field.humanize.titleize.t + ": " + v
        txt << "\n\n"
      end
    end
    txt << "PID".t + ": " + pid
    txt << "\n\n"
    txt << "Rating".t + ": " + rating.to_s
    txt << "\n\n"
    txt << "Votes".t + ": " + votes.to_s
    txt << "\n\n"
    # REWRITE: this needs to explicitly call the count
    # txt << "Comment count".t + ": " + comments.to_s
    txt << "Comment count".t + ": #{comments.size}"
    txt << "\n\n"
    txt << "Source".t + ": " + source.fulltitle
    txt << "\n\n"
    txt << Time.now.utc

    # REWRITE: we need one string here, the newlines are already there
    # txt
    txt.join
  end

  def display_field(display_field)
    if respond_to?(display_field)
      send(display_field)
    else
      elastic_record['_source'][display_field]
    end
  end

  def docvalue_field(docvalue_field)
    if elastic_record['fields'] && docvalue_field = elastic_record['fields'][docvalue_field]
      docvalue_field
    else
      ""
    end
  end

  def to_s
    descriptive_title
  end

  def descriptive_title(length = 80)
    @descriptive_title ||= begin
      t = []

      [[artist, title], [location]].each { |i|
        j = []
        i.each { |k| j << k if k && !(k = k.to_s.gsub(/\s+/, ' ').strip).empty? }
        t << (t.empty? ? j : j.parenthesize) unless (j = j.join(': ')).empty?
      }

      t.empty? ? path.gsub(/.*?\/|\.[^.]*\z/, '') : t.join(' ')
    end

    # REWRITE: not necessary anymore because strings support multibyte
    # unless length && (chars = @descriptive_title.chars).length > length
    unless length && (chars = @descriptive_title).length > length
      @descriptive_title
    else
      words = chars[0, length].split(/(\s+)/)

      title = words[0..-3].join.sub(/\W+\z/, '')
      title.empty? && words.find { |word| !word.blank? } || title
    end
  end

end
