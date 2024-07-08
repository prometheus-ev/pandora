class Comment < ApplicationRecord
  include Util::Attribution

  # REWRITE: presentation functionality is to be removed
  EAGER_LOADING       = [:image, :collection, :author, :parent]
  EAGER_LOADING_ROOTS = EAGER_LOADING + [{:replies => EAGER_LOADING}]

  belongs_to :image, optional: true
  belongs_to :collection, optional: true

  belongs_to :author,  :class_name => 'Account', :foreign_key => 'author_id', optional: true
  belongs_to :parent,  :class_name => 'Comment', :foreign_key => 'parent_id', optional: true
  has_many   :replies, lambda{includes(EAGER_LOADING)}, :class_name => 'Comment', :foreign_key => 'parent_id', :dependent => :destroy

  REQUIRED = %w[author_id text]

  validates_presence_of *REQUIRED

  def self.for(commentable, attribs = {})
    result = case commentable
    when Collection then new(collection_id: commentable.id)
    when Image then new(image_id: commentable.id)
    else
      raise Pandora::Exception, "invalid commentable: #{commentable}"
    end

    result.assign_attributes(attribs)

    result
  end

  def self.by_user(account)
    return all unless acount.present?

    where(author_id: account.id)
  end

  def self.roots
    where(parent_id: nil)
  end

  def self.not_deleted
    where('author_id IS NOT NULL')
  end

  def commentable
    collection || image
  end

  def type
    return 'collection' if commentable.is_a?(Collection)
    return 'image' if commentable.is_a?(Image)
  end

  def soft_delete!
    update_columns(
      author_id: nil,
      text: 'DELETED'
    )
  end

  def deleted?
    author_id.nil?
  end

  def to_s
    text[0, 40] << '...'
  end

  def anchor
    "comment-#{id}"
  end

  def last_changed
    [created_at, updated_at].max
  end

  def root
    parent_id ? parent.root : self
  end

  def object
    commentable
  end

  def by_owner?
    return super unless image_id && author_id

    src = image.source if image
    %w[contact admin].map{|key| src["#{key}_id"]}.include?(author_id) if src
  end
end
