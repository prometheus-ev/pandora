class Hash

  OPERATORS = Hash.new { |h, k| h[k] = k.to_s.upcase }.merge(
    :and => 'AND', :or => 'OR', :not => 'AND NOT'
  )

  def merge_html_options(add_options)
    dup.merge_html_options!(add_options)
  end

  def merge_html_options!(add_options)
    old_class, add_class = self[:class], add_options[:class]
    old_style, add_style = self[:style], add_options[:style]

    update(add_options.merge(
      :class => nil,
      :style => nil
    ))

    new_class = [old_class, add_class].reject(&:blank?).join(' ')
    new_style = [old_style, add_style].reject(&:blank?).join('; ')

    self[:class] = new_class unless new_class.blank?
    self[:style] = new_style unless new_style.blank?

    self
  end

  alias_method :update_html_options, :merge_html_options!

  def sort_by_key
    block_given? ? sort_by { |key, _| yield(key) } : sort_by { |key, _| key }
  end

  def hash
    inject(size) { |h, (k, v)| h ^ k.hash ^ v.hash }
  end

end
