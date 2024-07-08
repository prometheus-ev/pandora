module ProfileHelper
  def settings_select(form, key, options = nil)
    values = values_for_settings(form, key)

    form.select(key, case options
    when Array
      options.reject{|k, v| !values.include?(k) || v.blank?}.map(&:reverse)
    when Hash
      options.slice(*values).reject{|_, v| v.blank?}.invert.sort
    when Symbol
      send(options, values)
    when NilClass
      block_given? ? yield(values) : values.map{|v| [v.humanize.t, v]}
    else
      options
    end)
  end

  def values_for_settings(form, key)
    form.object.values_for(key)
  end
end
