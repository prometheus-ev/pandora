class Pandora::FormBuilder < ActionView::Helpers::FormBuilder
  def quarter_select(method, options = {})
    years = (-3..3).map{|i| Date.today.year + i}
    quarters = [1, 2, 3, 4]
    opts = years.map{|y| quarters.map{|q| "#{y}/#{q}"}}.flatten.sort
    select method, opts, options

    # REWRITE: this is difficult to replace now, let's do it later
    # InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_quarter_select_tag(options)
  end

  def upload_parent_selector
    candidates = object.
      available_parents(@template.current_user, object).
      includes(:parent)

    choices = candidates.map do |u|
      text = "#{u.id}: #{u.title}" + (u.parent ? " [#{u.parent.title}]" : '')
      [text, u.id]
    end

    select(
      :parent_id,
      choices,
      {include_blank: 'Available parent objects'.t},
      onchange: 'update_image();'
    )
  end
end
