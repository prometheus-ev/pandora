class Box < ApplicationRecord
  include Util::Attribution

  belongs_to :owner, :class_name => 'Account', :foreign_key => 'owner_id'
  belongs_to :image, optional: true
  belongs_to :collection, optional: true

  validates_presence_of :ref_type
  validates_presence_of :owner_id
  validates_presence_of :image_id,        :if => :image_box?
  validates_presence_of :collection_id,   :if => :collection_box?

  def self.order_by!(ids)
    p ids
    mapping = ids.map.with_index{|id, i| [id, i + 1]}.to_h
    p mapping
    all.to_a.each do |box|
      box.update_column :position, mapping[box.id.to_s]
    end
  end

  def category
    return 'image' if image_box?
    return 'collection' if collection_box?

    nil
  end

  def ref
    return image if image_box?
    return collection if collection_box?

    nil
  end

  def ref_id
    return image_id if image_box?
    return collection_id if collection_box?

    nil
  end

  def label
    "#{category.humanize.t}: #{title}"
  end

  ## Get the title of the object inside the box
  def title
    image_box? ? ref.descriptive_title(nil) : ref.title
  end

  ## Get a description for the object inside the box
  def description
    image_box? ? ref.descriptive_title(nil) : ref.description
  end

  ## Get ID for the page element
  def dom_id
    "box-#{id}"
  end

  def image_box?
    ref_type == 'image'
  end

  def collection_box?
    ref_type == 'collection'
  end
end
