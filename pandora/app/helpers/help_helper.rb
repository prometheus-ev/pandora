module HelpHelper
  # REWRITE: render :partial used to do just nothing if the partial didn't exist
  # this changed so now we need to catch the exception
  def submenu_extra
    render :partial => 'submenu_extra' if action_name != 'index'
  rescue ActionView::MissingTemplate => e
    Rails.logger.warn "failed to render submenu_extra partial for action #{action_name}"
    ''
  end

  def link_for_prev_next(item)
    { :action => item }
  end

  def link_to_prev_next(item, direction, title)
    super(item, direction, title && help_title(title, false))
  end

  def screenshot(img, title = nil, html_options = {})
    title = "Screenshot#{': ' if title}#{title}"
    image_tag(img, { :title => title, :class => 'screenshot' }.merge_html_options(html_options))
  end
end
