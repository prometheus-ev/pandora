# REWRITE: these helpers help easing the upgrade process and should eventually
# be removed/replaced

module UpgradeHelper
  def with_locale(locale, &block)
    Locale.switch_locale(locale, &block)
  end

  # copied from old rails version
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect{|object_name| instance_variable_get("@#{object_name}")}.compact
    end
    count = objects.inject(0){|sum, object| sum + object.errors.count}
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end

      options[:object_name] ||= params.first
      options[:header_message] ||= I18n.t('errors.template.header', count: count, model: options[:object_name])
      options[:message] ||= I18n.t('errors.template.body')

      error_messages = objects.sum([]){|object| object.errors.full_messages.map{|msg| content_tag(:li, msg)}}.join

      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) unless options[:header_message].blank?
      contents << content_tag(:p, options[:message]) unless options[:message].blank?
      contents << content_tag(:ul, error_messages.html_safe)

      content_tag(:div, contents.html_safe, html)
    else
      ''
    end
  end

  def distance_of_time_ago_in_words(from_time, include_seconds = true)
    opts = {
      include_seconds: include_seconds,
      scope: 'datetime.distance_in_words_ago'
    }
    distance_of_time_in_words Time.now, from_time, opts
  end

  def account_form_action(account, is_signup)
    return signup_path if is_signup

    if account.new_record?
      accounts_path
    else
      edit_account_path(account)
    end
  end

  def icon(which)
    tag('img', src: "/images/icon/#{which}.gif", class: 'icon')
  end

  def pm_section(name, options = {}, &block)
    locals = options.reverse_merge(
      name: name,
      title: name.humanize,
      header: true,
      icon: nil,
      expanded: false,
      content: capture(&block)
    )

    render partial: 'shared/section', locals: locals
  end

  def pm_submit(options = {})
    locals = options.reverse_merge(
      autosubmit: true,
      label: 'Submit'.t,
      cancel: false,
      value: 'Save'
    )

    render partial: 'shared/submit', locals: locals
  end

  def pm_comments_form_path(comment)
    opts = if comment.collection.present?
      {type: 'collection', commentable_id: comment.collection.id}
    elsif comment.image.present?
      {type: 'image', commentable_id: comment.image.id}
    else
      raise Pandora::Exception, "no commentable available on #{comment.inspect}"
    end

    if comment.new_record?
      comments_path(opts)
    else
      opts[:id] = comment.id
      comment_path(opts)
    end
  end

  def pm_comment_delete_url(comment)
    comment_path id: comment.id, type: comment.type, commentable_id: comment.commentable.id
  end

  def pm_l(time, opts = {})
    return nil unless time

    I18n.localize time, **opts
  end

  def link_to_image_tag(image, collection: nil)
    url_opts = {
      controller: 'images',
      action: 'show',
      id: image.pid,
      collection_id: collection ? collection.id : nil
    }

    link_to(url_opts,
            title: image.title) do
      image_tag(image.image_url,
                id: image.pid,
                _zoom_src: image.image_url(:medium),
                alt: '[' + 'Not available'.t + ']',
                title: hover_over_image_title(image).html_safe,
                onerror: "this.setAttribute('data-error', 'true');")
    end
  end

  def search_with_keyword_path(str)
    url_for(
      controller: 'searches',
      action: 'advanced',
      'search_field[0]' => 'keyword',
      'search_value[0]' => str
    )
  end

  def pm_titles_with_url(titles)
    results = titles.map do |title|
      unless title.include?(',http')
        next format_content(title, escape: false)
      end

      unless title.include?("%")
        next link_to_links(title)
      end

      arr = title.split('%')
      str = ""
      (0..(arr.count - 1)).each do |i|
        if !i.odd?
          str << arr[i]
        else
          str << link_to_links(arr[i])
        end
      end

      str
    end

    results.join(" | ").html_safe
  end
end
