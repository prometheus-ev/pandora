module MoreHelpers

  module ButtonHelper

    def create_button(text, button_type, options = {})
      button = '<div class="'
      button << 'autosubmit ' if options[:autosubmit] && !options[:disabled]
      button << 'scriptonly"'

      if name = options.has_key?(:name) ? options[:name] : 'commit'
        button << %Q{ _name="#{name}"}
      end

      button << ">\n" << <<-EOT
  <div class="button_wrap#{" #{button_type}_button" if button_type}">
    <div class="button_left"></div>
    <div class="button_icon"></div>
    <div class="button_middle">#{text}</div>
    <div class="button_right"></div>
  </div>
</div>
      EOT

      button.html_safe
    end

    def noscript_button(text, options = {}, button_type = nil)
      button = '<div class="noscript_button noscript">'

      unless external = action_name == 'js'
        button << image_tag('misc/button_send_left.gif')
        button << image_submit_tag("misc/button_icon_#{button_type}.gif", options) if button_type
      end

      button << submit_tag(text, options.merge_html_options(:class => 'submit'))
      button << image_tag('misc/button_send_right.gif') unless external

      button << '</div>' << "\n"

      button.html_safe
    end

    def submit_button(text = nil, options = {}, button_type = nil)
      float, cancel, cancel_text = [:float, :cancel, :cancel_text].map { |key| options.delete(key) }

      text        ||= 'Submit'.t
      cancel_text ||= 'Cancel'.t

      button = '<div class="submit_button_wrap'
      button << " float-#{float}" if float
      button << ' disabled' if options[:disabled]
      button << '">' << nl = "\n"
      button << autosubmit_button(text, :submit, options) << nl
      button << noscript_button(text, options, button_type) << nl

      button << '<div class="cancel_link">' << nl << 'or'.t << nl << (
        cancel.is_a?(Hash) && cancel.has_key?(:onclick) ?
          link_to(cancel_text, :back, cancel) : link_to(cancel_text, cancel)
      ) << nl << '</div>' << nl if cancel

      button << '</div>' << nl
      button.html_safe
    end

    def autosubmit_button(text, button_type, options = {})
      create_button(text, button_type, options.merge(:autosubmit => true))
    end

    def search_button(text = nil, options = {})
      submit_button(text || 'Search'.t, options.reverse_merge(:float => :right), :search)
    end

    def link_to_create(action = default = true)
      # REWRITE: override protected state for 'linkable_actions'
      # TODO: find better way
      action = (controller.send(:linkable_actions) & CREATE_ACTIONS).first if default
      if action && current_user && current_user.action_allowed?(controller_name, action)
        text_prefix = controller_name == 'upload' ? "New" : "Create a new"
        text = "#{text_prefix} #{(default ? controller_name.singularize : action).humanize}".t
        # REWRITE: unclear, why action == true makes any sense, setting a
        # seemingly good value
        action = 'new' if action == true
        link_to(create_button(text, :plus) << noscript_button(text), :action => action)
      end
    end

    def link_to_button(text = action_name.humanize, options = {}, html_options = nil)
      if (action = options[:action]) && current_user && current_user.action_allowed?(controller_name, action)
        link_to(create_button(text, :submit) << noscript_button(text), options, html_options)
      end
    end
  end

end
