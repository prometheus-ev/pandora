module PandoraHelper
  def author_durations(durations)
    durations.map {|from, till|
      if from && till
        "#{from.to_fs(:coarse)} - #{till.to_fs(:coarse)}"
      elsif from
        'since %s' / from.to_fs(:coarse)
      elsif till
        'until %s' / till.to_fs(:coarse)
      end
    }.join(', ')
  end

  def see_also(text, url_options = {})
    'see %s'.t.html_safe % link_to(text.html_safe, url_options).html_safe
  end
end
