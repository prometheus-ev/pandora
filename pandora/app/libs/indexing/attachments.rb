class Indexing::Attachments
  def initialize(source_name)
    @source_name = source_name
  end

  def self.strip(record)
    ['rating_count', 'rating_average', 'comment_count', 'user_comments'].each do |k|
      record.delete k
    end

    record
  end

  def enrich(record)
    pid = record['record_id']
    field_validator = Indexing::FieldValidator.new

    field_validator.validate('rating_count', ratings_for(pid)[:count])
    field_validator.validate('rating_average', ratings_for(pid)[:average])
    field_validator.validate('comment_count', comments_for(pid).size)
    field_validator.validate('user_comments', comments_for(pid).join('; '))
    field_validator.validate('artist_normalized', record['artist_normalized'])

    record.merge!(field_validator.validated_fields)

    if um = user_metadata_for(pid)
      record.merge! um.update_attribs_for(record, strict_original_checking: true)
    end

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

  def user_metadata_for(pid)
    unless @user_metadata
      @user_metadata = {}

      user_metadata_scope.find_each do |um|
        @user_metadata[um.pid] = um
      end
    end

    @user_metadata[pid]
  end


  private

    def comment_scope
      Comment.where('image_id LIKE ?', "#{@source_name}-%")
    end

    def rating_scope
      Image.
        where('pid LIKE ?', "#{@source_name}-%").
        where('votes > 0')
    end

    def user_metadata_scope
      UserMetadata.where('pid LIKE ?', "#{@source_name}-%")
    end
end
