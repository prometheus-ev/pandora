module MoreHelpers

  module NavigationHelper

    # def navigation_default_for(key)
    #   target = NAVIGATION_DEFAULT[key]

    #   case target
    #     when String
    #       target
    #     when Array
    #       ivars, target = target.dup, nil
    #       default = ivars.pop

    #       ivars.each { |ivar|
    #         target = instance_variable_get("@#{ivar}")
    #         target = target.first if target.is_a?(Array)  # ???

    #         break if target.is_a?(String)
    #       }

    #       target || default
    #   end
    # end

    # def navigation_link_to(ctrl, active = false)
    #   status = active ? 'active' : 'inactive'
    #   title = {
    #     'searches' => 'Search'.t,
    #     'collections' => 'Collections'.t,
    #     'uploads' => 'My Uploads'.t
    #   }[ctrl] || ctrl.titleize.t

    #   # REWRITE: url_for(controller: 'bla') now always assumes the index action
    #   # which isn't what we want for the search controller for now
    #   opts = {controller: ctrl}

    #   case ctrl
    #     when 'searches'
    #       opts[:action] = 'index'
    #     when 'uploads'
    #       if current_user && current_user.institutional_user_dbadmin?
    #         opts = institutional_databases_path
    #       end
    #   end

    #   link_to(
    #     %Q{<div class="navigation_icon #{ctrl}_navigation #{status}" title="#{title}"><span>#{title}</span></div>}.html_safe,
    #     # REWRITE: see above
    #     # :controller => ctrl
    #     opts
    #   )
    # end

    # def navigation_links_to(*controllers)
    #   controllers.reject!(&:blank?)

    #   options = controllers.extract_options!

    #   if options.has_key?(:condition) ? options[:condition] : current_user
    #     active = options.has_key?(:active) ? options[:active] : controller_name != "institutional_uploads" ? controller_name : "uploads"
    #     active = navigation_default_for(active) unless controllers.include?(active)
    #   end

    #   controllers.map { |ctrl| navigation_link_to(ctrl, ctrl == active) }.join('').html_safe
    # end

    def submenu_link_to(name, options, html_options = {})
      current = options.all? { |param, value| value.nil? || params[param] == value.to_s }
      text = %Q{<div class="menu_link #{current ? 'active' : 'inactive'}">#{name}</div>}

      text = %w[left right].map { |pos|
        %Q{<div class="menu_link_border #{pos}"></div>}
      }.join(text) if current

      link_to(text.html_safe, options.merge(:id => nil), html_options)
    end

    def submenu_links
      # REWRITE: override protected state for 'linkable_actions'
      # TODO: find better way
      actions = controller.send(:linkable_actions) - CREATE_ACTIONS
      allowed_actions_for_current_user(actions).map { |action|
        submenu_link_to(action.humanize, :action => action)
      }.join.html_safe
    end

    def submenu_extra
      # dummy
    end

    # renders a link to a help page, the page
    # @param [Hash] options the options with which to create the link
    # @option options [String] :label ('Help'.t) the link text, also an icon 
    #   works
    # @option options [String] :title (same as :label) the title attribute
    # @option options [String] :class (nil) css classes to apply
    # @option options [String] :anchor (nil) url fragment (#sub-heading) to use
    def link_to_help(options = {})
      options.reverse_merge!(
        label: 'Help'.t,
        class: nil,
        host: request.host
      )
      options[:title] ||= options[:label]

      link_to(
        options[:label],
        help_url(section: options[:section], host: options[:host], anchor: options[:anchor]),
        {title: options[:title], class: options[:class]}
      )
    end

    def help_icon
      image_tag('misc/help.gif', host: request.host)
    end


  end

end
