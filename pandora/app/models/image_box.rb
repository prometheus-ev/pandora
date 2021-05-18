class ImageBox < Box

  def title
    object.descriptive_title(nil)
  end

  alias_method :description, :title

end
