# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include MoreHelpers
  include UpgradeHelper

  NUMERIC_CSS_RE = /\b(?:bottom|height|left|margin|padding|right|top|width)\b/

  def controller_name
    @controller_name ||= controller.controller_name
  end

  def action_name
    @action_name ||= controller.action_name
  end

  def controller_title
    subject, verb, extra = segments_for_controller_title
    title = [subject, verb].compact.map(&:t).join(': ')
    extra ? "#{title} #{extra}" : title
  end

  def page_title
    subject, verb, extra = segments_for_controller_title { |object, name|
      name ? link_to_object(object, name) : link_to_object(object)
    }

    title = [verb, subject].compact.join(' ').capitalize_first.t
    %Q{<h2 class="page_title">#{extra ? "#{title} #{extra}" : title}</h2>}.html_safe
  end

  def segments_for_controller_title
    if object = object_for_controller and !object.new_record?
      extra = if respond_to?(method = "title_for_#{controller_name}")
        send(method, object) { |oname|
          %Q{"#{block_given? ? yield(object, oname) : oname}"}
        }
      else
        # REWRITE: doesn't seem to be reached
        if controller_name == "images"
          %Q{"#{block_given? ? yield(object) : sanitize(object.to_s)}"}
        else
          %Q{"#{block_given? ? yield(object) : h(object)}"}
        end
      end
    end

    subject, verb = controller_name.humanize, action_name.humanize

    case action_name
      when 'show'
        verb = nil
      when 'show_athene_search'
        verb = nil
      when *%w[history license ratings recipients settings]
        verb = "#{verb} for"
      when *%w[email]
        subject = nil
        verb = "Compose #{verb}"
    end

    [subject, verb, extra]
  end

  def object_name_for_controller
    @object_name_for_controller ||= !(controller_name == 'institutional_uploads')? controller_name : 'uploads'
  end

  def object_for_controller
    @object_for_controller ||= instance_variable_get("@#{object_name_for_controller}")
    @object_for_controller if @object_for_controller.is_a?(ApplicationRecord)
  end

  def objects_for_controller
    @objects_for_controller ||= instance_variable_get("@#{object_name_for_controller.to_s.pluralize}")
  end

  def format_content(content, options = {})
    options.reverse_merge!(:truncate_at => 200, :escape => true, :separator => ' | ')

    content = [*content].join(options.delete(:separator))
    (truncate_at = options.delete(:truncate_at)) ? truncated(content, truncate_at, options) : content
  end

  def switch_locale_path(locale)
    # REWRITE: we can just use the url helper here
    # request.path.gsub(/(^(\/en|de))?(\/.*)$/, "/de\\3")
    if request.get?
      url_for params.permit!.merge(locale: locale)
    else
      url_for locale: locale
    end
  end

  def classes_for_field(field, klass = nil)
    [ klass,
      @mandatory && @mandatory[field.to_s] && 'mandatory',
      @prompt    && @prompt[field]    && 'prompt',
    ].reject(&:blank?).join(' ')
  end

  def classes_for_comment(comment)
    classes = %w[comment]

    if comment.by?(current_user)
      classes << 'comment-user'
    elsif comment.by_owner?
      classes << 'comment-owner'
    end

    classes.join(' ')
  end

  def classes_for_body
    %Q{#{controller_name}-controller #{action_name}-action nojs}
  end

  def icon_for_active_inactive(condition, path, img_options = {}, link_options = {}, html_options = {})
    img = image_tag(path % (condition ? '' : '_inactive'), img_options)

    condition ? block_given? ? yield(img, link_options, html_options) : link_to(img, link_options, html_options) : img
  end

  def link_for_prev_next(item)
    { :id => item }
  end

  def link_to_prev_next(item, direction, title = direction)
    icon_for_active_inactive(item, "misc/#{direction}%s.gif", { :title => title && title.t }, link_for_prev_next(item))
  end

  def link_to_prev_item(item, title = 'Previous item')
    link_to_prev_next(item, :prev, title)
  end

  def link_to_next_item(item, title = 'Next item')
    link_to_prev_next(item, :next, title)
  end

  def link_to_item_top(top, title = "Back to #{top && top[0] || 'top'}")
    icon_for_active_inactive(top, "misc/up%s.gif", { :title => title.t }, top && top[1])
  end

  def email_icon_for(source, element = :div)
    if source.user_database?
      link_to(%Q{<#{element} class="email"></#{element}>}.html_safe,
        { :controller => 'accounts', :action => 'email', :to => source.owner },
        :title => 'Send a message to the owner of the user database'.t
      )
    else
      if inactive = (email = source.email).present?
        mail_to(email,
          %Q{<#{element} class="email#{' inactive' if inactive}"></#{element}>}.html_safe,
          :title => 'Send e-mail to the person in charge for the database'.t
        )
      end
    end
  end

  def source_icons_for(source)
    icons = []

    icons << link_to_unless(inactive = (url = source.url).blank?,
      %Q{<div class="home#{' inactive' if inactive}"></div>}.html_safe,
      url,
      :title  => "Go to the database's homepage".t,
      :target => '_blank'
    )

    # REWRITE: this class is not available anymore, making the determination
    # on the type column for now
    # if source.is_a?(Source::Upload)
    if source.upload?
      icons << link_to(
        '<div class="email"></div>'.html_safe,
        { :controller => 'accounts', :action => 'email', :to => source.owner }
      )
    else
      icons << email_icon_for(source)
    end

    icons << link_to_unless(
      inactive = false,
      %Q{<div class="info#{' inactive' if inactive}"></div>}.html_safe,
      { :controller => 'sources', :action => 'show', :id => source },
      :title  => 'Information about the database'.t,
      :target => '_blank'
    )

    (@source_icons_for ||= {})[source.id] ||= begin
      result = (
        '<div class="source_icons dim">' +
        icons.compact.join(' ') +
        '</div>'
      )
      result.html_safe
    end
  end

  def link_to_vgbk(image = nil)
    link_to('VG Bild-Kunst', 'http://www.bildkunst.de') unless image && image.vgbk.blank?
  end

  def link_to_warburg(image = nil)
    link_to('The Warburg Institute, London', 'http://warburg.sas.ac.uk/archive/') if !image || Image.rights_warburg?(image)
  end

  def rights_representative(image, i = true)
    link_to_warburg(image) || (i && !(e = image.rights_work).blank? && h(Upload.pconfig[:rights_work].include?(e) ? e.t : e)) || link_to_vgbk(image)
  end

  def external_image_tag(source, options = {}, external = action_name == 'js')
    image_tag(external ? "#{base_url}#{image_path(source)}" : source, options)
  end

  # def asset_path_for(target, subtarget = nil, skip_base = false)
  #   path = case target
  #     when :controller
  #       controller_name != 'institutional_uploads'? controller_name : 'uploads'
  #     when :action
  #       controller_name != 'institutional_uploads'? asset_path_for(controller_name, action_name, true) : asset_path_for('uploads', action_name, true)
  #     else
  #       File.join(target, subtarget)
  #   end

  #   # We like to keep our application-specific stylesheets and javascripts in
  #   # a subdirectory named 'app'.
  #   skip_base ? path : File.join('app', path)
  # end

  # def javascript_include_tag_for(target, subtarget = nil)
  #   path = asset_path_for(target, subtarget)
  #   javascript_include_tag(path) if File.exists?(Rails.root.join('public', 'javascripts', "#{path}.js"))
  # end

  def apply_behaviour(*args)
    javascript_tag %Q{Pandora.Behaviour.apply(#{args.map(&:inspect).join(',')});} if request.xhr?
  end

  def allowed_actions_for_current_user(actions = controller.linkable_actions)
    current_user ? current_user.allowed_actions(controller_name, actions).map(&:to_s) : []
  end

  # Generate link from text and URL string in form of "text,URL".
  def link_to_links(text_and_url)
    text_and_url = text_and_url.rpartition(',http')
    "#{link_to(text_and_url.first.html_safe, 'http' + text_and_url.last, :target => '_blank')}"
  end

  def link_to_google_maps(query)
    link_to(%Q{<div class="google_maps dim"></div>}.html_safe, "https://maps.google.com/maps?q=#{url_encode(query)}", :title => 'on Google Maps'.t, :target => '_blank')
  end

  def is_url?(string)
    begin
      uri = URI.parse(string)
      if ['http', 'https'].include?(uri.scheme)
        true
      else
        false
      end
    rescue
      false
    end
  end

  def public_user(user = current_user, condition = false)
    if condition || user && (user.active? || current_user && current_user.admin_or_superadmin?)
      user
    else
      'N.N.'.t
    end
  end

  def link_to_profile(user = default = current_user, options = {}, html_options = {})
    user = public_user(user, options.delete(:public) || default)

    if user.is_a?(Account)
      link_to_if_allowed(name = h(user.fullname),
        options.merge(:controller => 'accounts', :action => 'show', id: user.login),
        { :title => user == current_user ? 'Your profile'.t : "%s's profile" / name }.merge(html_options)
      )
    else
      link_to_help(
        label: user,
        section: 'profile',
        anchor: 'N.N.',
        class: 'help'
      )
    end
  end

  def link_to_profile_with_email(user, email = user.email, options = {}, html_options = {}, img_options = {})
    link = ''
    link += link_to_profile(user, options, html_options) if user
    link += ' ' + mail_to(h(email), image_tag('misc/email.gif', img_options)) if email
    link.html_safe
  end

  def link_to_admin_profile_with_email(admin, email = admin.email, options = {}, html_options = {}, img_options = {})
    admin_email = admin.institution == (prometheus = Institution.find_by!(name: 'prometheus')) ? prometheus.email : email
    link_to_profile_with_email(admin, admin_email, options, html_options) if admin
  end


  def link_to_author(object)
    link = link_to_profile(object.author)

    if object.by?(current_user)
      "#{link} (<strong>#{'You'.t}</strong>)".html_safe
    elsif object.by_owner?
      "#{link} (#{"#{object.object.class} owner".t})".html_safe
    else
      link
    end
  end

  def link_to_if_allowed(name, options = {}, html_options = {})
    link_to_if(
      current_user && current_user.action_allowed?(options[:controller] || controller_name, options[:action]),
      name, options, html_options
    )
  end

  def hidden_field_tags_for(params, options = {}, ignore = %w[controller action])
    # REWRITE: needs a hash instead
    # params.map { |name, value|
    params.to_h.map { |name, value|
      next if ignore.include?(name.to_s)

      case value
        when Array
          hidden_field_tags_for(value.map { |v| ["#{name}[]", v] }, options)
        else
          hidden_field_tag(name, value, options)
      end
    }.compact.join('').html_safe
  end

  def options_for_select_t(container, selected = nil)
    container = container.to_a if container.is_a?(Hash)

    options_for_select(container.map { |option|
      text, value = option_text_and_value(option)
      [text.t, value]
    }, selected)
  end

  def options_for_order_select(args)
    [*args].compact.map { |title, order|
      if title.respond_to?(:human_name)
        order ||= title.name
        title = title.human_name
      else
        order ||= title.underscore.gsub(/\s+/, '_')
        title = title.tr('.', '_').humanize
      end

      [title.t, order]
    }
  end

  def options_for_field(field, options = {})
    options.merge_html_options(:class => classes_for_field(field, options[:class]))
  end

  def link_to_toggle_zoom(toggle_class, enable_text = 'Enable zoom'.t, disable_text = 'Disable zoom'.t)
    # REWRITE: horrible, check if it works. Use ujs.
    link_to(
      "<div class=\"zoom_link #{zoom ? 'enabled' : 'disabled'}\"></div>".html_safe,
      safe_params(zoom: !zoom),
      class: toggle_class,
      title: zoom ? disable_text : enable_text,
      _zoom_enabled: zoom.to_s
    )
  end

  def link_to_open_source(source, name = 'Open Access'.t, condition = !current_user || current_user.dbuser?)
    title = h(source.title)

    link_to_if condition && source.open_access?, name || title,
      open_access_source_url(source),
      { :title => 'Enter "%s"' / title }
  end

  ## === Buttons for boxes within the sidebar ===================================

  # generates a url to an item (collection / image) referenced by a given box
  # respecting the current locale
  # @param [String] box the box to generate the url for
  # @return [String] the url to the box item
  def url_for_box(box, url_opts = {})
    case box.category
    when 'image'
      url_for url_opts.reverse_merge(
        controller: 'images',
        action: 'show',
        id: box.image_id
      )
    when 'collection' then collection_path(box.collection_id, url_opts)
    else
      raise Pandora::Exception, "box #{box.inspect} has unknown type"
    end
  end

  def link_to_close_box(box)
    link_to(
      '<div class="close"></div>'.html_safe,
      '#',
      data: {
        'pm-confirm': "Are you sure to delete Box: '%s'" / box.title,
        id: box.id
      },
      title: 'Close'.t,
      class: 'pm-from-sidebar'
    )
  end

  # def link_to_close_box(options, html_options = {}, remote = true)
  #   text = '<div class="close"></div>'.html_safe

  #   if remote
  #     link_to(
  #       text,
  #       url_for(options),
  #       data: html_options[:data],
  #       remote: true,
  #       method: 'DELETE',
  #       title: 'Close'.t
  #     )
  #   else
  #     link_to(text, options, html_options)
  #   end
  # end

  ## Toggle the visibility of the box (collapsed/expanded)
  def link_to_toggle_announcements(expanded, session_key, box_id = nil, expand_text = 'Expand'.t, collapse_text = 'Collapse'.t)
    link_to(
      %Q{<span class="scriptonly box_toggle"><div class="#{expanded ? 'collapse' : 'expand'}"></div></span>}.html_safe,
      '#',
      onclick: "toggle_box('#{box_id ? 'box_content' : 'box'}', '#{box_id}', '#{session_key}', '#{expand_text}', '#{collapse_text}')",
      title: expanded ? collapse_text : expand_text
    )
  end
  
  def link_to_toggle_box(box)
    text = %Q{<span class="scriptonly box_toggle"><div class="#{box.expanded? ? 'collapse' : 'expand'}"></div></span>}.html_safe

    link_to(
      text,
      '#',
      data: {id: box.id},
      title: box.expanded? ? 'Collapse'.t : 'Expand'.t,
      class: 'pm-toggle-box'
    )
  end

  ## === Announcement =========================================================

  def current_announcements
    if current_user && current_user.announcement_hide_time
      since_then = current_user.announcement_hide_time
    else
      since_then = ''
    end

    # REWRITE: we have to ensure utc so that athene doesn't get confused
    if since_then.present?
      since_then = since_then.to_s(:utc)
    end

    @current_announcements ||= Announcement.current.since(since_then).to_a
    @current_announcements.delete_if { |announcement| !announcement.allowed?(current_user) }
  end

  ## === Box ==================================================================

  # Creates link for box creation.
  # @param name [String] the type of the object, e.g. "image", "collection".
  # @param long [Boolean] ?.
  # @param box_params [Hash] a hash containing params :controller, :action and :id for the box.
  # @return [String] the hyperlink tag for box create action.
  # REWRITE: only remove unsafe options from selected params.
  # def add_to_sidebar(name = nil, long = false, box_params = safe_params)
  def add_to_sidebar(name = nil, long = false, box_params = {})
    box_params = box_params.except(*ApplicationController::UNSAFE_OPTIONS)
    text = "Add #{name || object_name_for_controller} to sidebar".t

    args = [{
      url: options = { controller: 'box', action: 'create', box: box_params }
    }, {
      href: url_for(options),
      method: 'POST',
      remote: true,
      class: object_name_for_controller + '-to-sidebar'
    }]

    # REWRITE: this is done via ujs now (activate it!)
    link = link_to(image_tag('misc/add_to_sidebar.gif', :class => 'icon', :title => text), *args)
    long ? link << ' ' << link_to(long.is_a?(String) ? long : text, *args) : link
  end

  # An image submit tag that actually works.
  # (cf. <https://bugzilla.mozilla.org/show_bug.cgi?id=583211>)
  def image_submit_tag(source, options = {})
    style = "background-image: url(#{path_to_image(source)})"

    # 'icon' and 'delete-icon' have 1px border
    border = options[:class] =~ /\bicon\z/ ? 2 : 0

    width, height = GEOMETRY_FOR[source]
    style << "; width: #{width + border}px; height: #{height + border}px" if width && height
    style << '; display: block' if request.user_agent =~ /MSIE/

    submit_tag(options.delete(:value), { :class => 'image_submit_tag', :style => style }.merge_html_options(options))
  end

  def distance_of_time_in_days_or_weeks(from_time, to_time = 0)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time   = to_time.to_time   if to_time.respond_to?(:to_time)

    days = ((to_time - from_time) / 1.day).round

    if days > 14
      '%d weeks' / (days / 7).round
    else
      '%d days' / days
    end
  end

  def distance_of_time_ago_in_words_tag(from_time)
    %Q{<abbr title="#{from_time}">#{distance_of_time_ago_in_words(from_time)}</abbr>}.html_safe
  end

  def gogif
    image_tag('misc/go.gif', :class => 'go_icon')
  end

  def format_address_for(object, fields = %w[addressline city_with_postalcode country], separator = '<br />')
    values = fields.map { |field|
      value = object.send(field)
      next if value.blank?

      case field
        when 'addressline'
          h(value.strip).gsub(TEXTAREA_SEPARATOR_RE, '<br />')
        when 'country'
          h(value.t)
        else
          h(value)
      end
    }.compact

    values.join(separator).html_safe unless values.empty?
  end

  def display_login?
    !current_user || current_user.anonymous?
  end

  def display_campus_login?
    return @campus if defined?(@campus)
    @campus = (!current_user || current_user.dbuser?) && Institution.find_by_ip(request.remote_ip)
  end

  # used in accounts and signup views at least
  def localize_expiry_date(user)
    if user.expires_at && !user.exempt_from_expiration?
      if [Date, DateTime, Time].any? { |c| user.expires_at.is_a? c }
        localize(user.expires_at, :format => :long)
      else
        user.expires_at.to_s
      end
    else
      "Saint Glinglin's Day".t
    end
  end

end
