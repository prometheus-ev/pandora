class Indexing::Attachments
  def initialize(source_name)
    @source_name = source_name
    @comments_count = preprocess_comments
    @ratings_count = preprocess_ratings
    @user_metadata_count = preprocess_user_metadata
    @vectors_count = preprocess_vectors
    @unseen_pids = collect_pids
  end

  attr_reader :comments_count, :ratings_count, :user_metadata_count, :vectors_count

  def self.strip(record)
    ['rating_count',
     'rating_average',
     'comment_count',
     'user_comments',
     'image_vector'].each do |k|
      record.delete k
    end

    record
  end

  def enrich(record)
    pid = record['record_id']
    @unseen_pids.delete(pid)

    field_validator = Indexing::FieldValidator.new
    field_validator.validate('rating_count', ratings_for(pid)[:count])
    field_validator.validate('rating_average', ratings_for(pid)[:average])
    field_validator.validate('comment_count', comments_for(pid).size)
    field_validator.validate('user_comments', comments_for(pid).join('; '))
    field_validator.validate('artist_normalized', record['artist_normalized'])
    field_validator.validate('image_vector', vector_for(pid))

    record.merge!(field_validator.validated_fields)

    if um = user_metadata_for(pid)
      record.merge! um.update_attribs_for(record, strict_original_checking: true)
    end

    record
  end

  def comments_for(pid)
    @comments[pid] || []
  end

  def ratings_for(pid)
    @ratings[pid] || {}
  end

  def user_metadata_for(pid)
    @user_metadata[pid]
  end

  def vector_for(pid)
    @vectors[pid]
  end

  def counts
    return {
      comments: @comments.keys.size,
      ratings: @ratings.keys.size,
      user_metadata: @user_metadata.keys.size,
      vectors: @vectors.keys.size
    }
  end

  def orphans
    pids = @unseen_pids.keys

    return {
      comments: comment_scope.where('image_id NOT IN (?)', pids).pluck(:image_id),
      ratings: rating_scope.where('pid NOT IN (?)', pids).pluck(:pid),
      user_metadata: user_metadata_scope.where('pid NOT IN (?)', pids).pluck(:pid),
      vectors: vector_scope.keys - @unseen_pids.keys
    }
  end

  private

    def preprocess_comments
      @comments = {}

      comment_scope.find_each do |comment|
        @comments[comment.image_id] ||= []
        @comments[comment.image_id] << comment.text
      end

      @comments.values.flatten.size
    end

    def preprocess_ratings
      @ratings = {}

      rating_scope.find_each do |image|
        @ratings[image.pid] = {
          average: image.rating,
          count: image.votes
        }
      end

      @ratings.keys.count
    end

    def preprocess_user_metadata
      @user_metadata = {}

      user_metadata_scope.find_each do |um|
        @user_metadata[um.pid] = um
      end

      @user_metadata.keys.count
    end

    def preprocess_vectors
      @vectors = {}

      vector_scope.each do |pid, data|
        vector = data.dig("features", "similarity", pid, "vector")

        if vector && !vector.empty?
          vector = JSON.parse(vector)
          @vectors[pid] = vector unless vector.empty?
        end
      end

      @vectors.keys.count
    end

    def collect_pids
      result = (
        @comments.keys +
        @ratings.keys +
        @user_metadata.keys +
        @vectors.keys
      )

      result.to_h{|pid| [pid, true]}
    end

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

    def vector_scope
      Pandora::SuperImage.load_vectors(@source_name)
    end
end
