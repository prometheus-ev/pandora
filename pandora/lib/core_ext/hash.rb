class Hash

  OPERATORS = Hash.new { |h, k| h[k] = k.to_s.upcase }.merge(
    :and => 'AND', :or => 'OR', :not => 'AND NOT'
  )

  def merge_conditions(add_conditions, op = :and)
    dup.merge_conditions!(add_conditions, op)
  end

  def merge_conditions!(add_conditions, op = :and)
    if add_conditions.is_a?(Hash)
      hash = add_conditions.dup

      update_include(hash.delete(:include)) if hash.has_key?(:include)
      update_joins(hash.delete(:joins))     if hash.has_key?(:joins)

      add_conditions = hash.delete(:conditions)

      update(hash)
    end

    return self if add_conditions.blank?

    old_conditions = self[:conditions]
    new_conditions = unless old_conditions.blank?
      add_query, *add_values = add_conditions

      op = OPERATORS[op]

      case old_conditions
        when Array
          old_query, *old_values = old_conditions

          ["(#{old_query}) #{op} (#{add_query})", *(old_values + add_values)]
        when String
          ["(#{old_conditions}) #{op} (#{add_query})", *add_values]
      end
    else
      add_conditions
    end

    update(:conditions => new_conditions)
  end

  alias_method :update_conditions, :merge_conditions!

  def merge_include(add_include)
    dup.merge_include!(add_include)
  end

  def merge_include!(add_include)
    return self if add_include.blank?

    old_include = self[:include]
    new_include = unless old_include.blank?
      old_include = [old_include] unless old_include.is_a?(Array)
      add_include = [add_include] unless add_include.is_a?(Array)

      old_include | add_include
    else
      add_include
    end

    update(:include => new_include)
  end

  alias_method :update_include, :merge_include!

  def merge_joins(add_joins)
    dup.merge_joins!(add_joins)
  end

  def merge_joins!(add_joins)
    return self if add_joins.blank?

    old_joins = self[:joins]
    new_joins = unless old_joins.blank?
      if old_joins.is_a?(String) && add_joins.is_a?(String)
        [old_joins, add_joins].reject(&:blank?).join(' ')
      else
        old_joins = [old_joins] unless old_joins.is_a?(Array)
        add_joins = [add_joins] unless add_joins.is_a?(Array)

        old_joins | add_joins
      end
    else
      add_joins
    end

    update(:joins => new_joins)
  end

  alias_method :update_joins, :merge_joins!

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
