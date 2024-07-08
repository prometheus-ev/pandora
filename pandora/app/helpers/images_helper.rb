module ImagesHelper
  def segments_for_controller_title
    segments = super
    segments[1] = 'Copyright and publishing information for' if action_name == 'publish'
    segments
  end

  def submenu_extra
    if action_name == 'show'
      render :partial => 'images/submenu_extra'
    end
  end

  def editable_section?(section)
    super && section != 'details'
  end

  def show_credit(credit)
    if is_url?(credit)
      link_to(credit, credit, :target => '_blank')
    elsif credit.include?(",http")
      link_to_links(credit)
    else
      format_content(credit, :escape => false)
    end
  end
end
