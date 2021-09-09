class Box < ApplicationRecord
  include Util::Attribution

  # serialize :params, Hash

  belongs_to :owner, :class_name => 'Account', :foreign_key => 'owner_id'
  belongs_to :image, optional: true
  belongs_to :collection, optional: true

  # attr_protected :type, :created_at, :updated_at,
  #   :owner_id, :image_id, :collection_id

  validates_presence_of :ref_type
  validates_presence_of :owner_id
  validates_presence_of :image_id,        :if => :image_box?
  validates_presence_of :collection_id,   :if => :collection_box?

  # def self.from_params(params, target = nil)
  #   type = params[:type] || params[:box][:controller]
  #   if type == "images"
  #     ImageBox.from_hash(params[:box], target)
  #   elsif type == 'collections'
  #     CollectionBox.from_hash(params[:box], target)
  #   else # REWRITE: TODO: for collections; presentations do not exist anymore
  #     "#{type.to_s.camelize}Box".constantize.from_hash(params[:box], target)
  #   end
  # end

  # def self.from_hash(hash, target = nil)
  #   raise 'must be called on child class' if self == Box

  #   # REWRITE: use tap instead
  #   # returning(new) { |box|
  #   new.tap { |box|
  #     if id = hash[:id] and assoc = reflect_on_association(category.to_sym)
  #       id = hash[:id] = id.id if id.is_a?(ActiveRecord::Base)
  #       #REWRITE: it seems that this is now foreign_key
  #       # box[assoc.primary_key_name] = id
  #       box[assoc.foreign_key] = id
  #     end

  #     box.position = (target.maximum(:position) || 0) + 1 if target

  #     # TODO: verify that this is no security problem
  #     # box.params = hash.permit!.to_h

  #     target ? target << box : box.save
  #   }
  # end

  # def self.order(ids, target)
  #   target.each { |box|
  #     !(index = ids.index(box.id)) ? box.destroy :
  #       box.update_attribute(:position, index + 1)
  #   }

  #   target.reset
  # end

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

  # def boxable
  #   collection || image
  # end

  ## Determine object type from parameters
  # def object
  #   @object ||= image_id        ? image        :
  #               collection_id   ? collection   : nil
  # end

  # def object?
  #   image_id || collection_id
  # end
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

  # def category
  #   self.class.category
  # end

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

  # getter/setter for params
  # fix for legacy controller name "image" still set by prometheus App
  # def params
  #   if self[:params]["controller"] && self[:params]["controller"] == "image"
  #     self[:params]["controller"] = "images"
  #   end
  #   self[:params]
  # end

  # def params=(params)
  #   if params["controller"] && params["controller"] == "image"
  #     params["controller"] = "images"
  #   end
  #   self[:params] = params
  # end

  def image_box?
    ref_type == 'image'
  end

  def collection_box?
    ref_type == 'collection'
  end
end
