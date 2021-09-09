class Indexing::Attachments
  def initialize(source)
    @source = source
  end

  def self.strip(record)
    ['rating_count', 'rating_average', 'comment_count', 'user_comments'].each do |k|
      record['_source'].delete k
    end

    record
  end

  def enrich(record)
    pid = record['_id']
    field_validator = Indexing::FieldValidator.new

    field_validator.validate('rating_count', ratings_for(pid)[:count])
    field_validator.validate('rating_average', ratings_for(pid)[:average])
    field_validator.validate('comment_count', comments_for(pid).size)
    field_validator.validate('user_comments', comments_for(pid).join('; '))
    field_validator.validate('artist_normalized', record['_source']['artist_normalized'])

    record['_source'].merge!(field_validator.validated_fields)
    record
  end

  def comments_for(pid)
    unless @comments
      @comments = {}
      comment_scope.find_each do |comment|
        @comments[comment.image_id] ||= []
        @comments[comment.image_id] << comment.text
      end
    end

    @comments[pid] || []
  end

  def ratings_for(pid)
    unless @ratings
      @ratings = {}
      rating_scope.find_each do |image|
        @ratings[image.pid] = {
          average: image.rating,
          count: image.votes
        }
      end
    end

    @ratings[pid] || {}
  end


  private

    def comment_scope
      Comment.where('image_id LIKE ?', "#{@source}-%")
    end

    def rating_scope
      Image.
        where('votes > 0').
        where(source_id: Source.find_by!(name: @source).id)
    end
end
