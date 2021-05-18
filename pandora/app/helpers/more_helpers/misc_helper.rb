module MoreHelpers

  module MiscHelper

    def show_action
      'show'
    end

    def edit_action
      'edit'
    end

    def form_controls(text = nil, options = {})
      render :partial => 'shared/misc/form_controls', :locals => {
        :text => text || 'Save'.t, :options => options.reverse_merge(:cancel => :back)
      }
    end

    def remote_edit_link_to(object, section, options = {}, html_options = {}, text = nil)
      url_options = { :action => edit_action, :id => object }.merge(options)

      html_options = { :title => 'Edit this section'.t }.merge(html_options)

      link_to(
        text || image_tag('icon/edit.gif', class: 'icon'),
        url_options.merge(:section => section, :anchor => nil),
        {
          :method => 'get',
          :remote => true
        }.reverse_merge(html_options)
      )
    end

    def link_to_edit_section(object, section)
      # REWRITE: see remote_edit_link_to
      # remote_edit_link_to(object, section, {}, { :class => 'icon' }) if current_user && current_user.allowed?(object)
      remote_edit_link_to(object, section) if current_user && current_user.allowed?(object)
    end

    def edit_section?(section)
      section =~ /_settings\z/
    end

    def editable_section?(section)
      !edit_section?(section) && !%w[
        advanced basic comments images slides
        public_collections shared_collections
        public_presentations shared_presentations
        user_administrators databases departments
        legacy_presentations
      ].include?(section)
    end

    def render_section(object, section, locals = {})
      optional = section.respond_to?(:sub!) && section.sub!(/\?\z/, '')
      expanded = section.respond_to?(:sub!) && section.sub!(/!\z/, '')

      count = section == "legacy_presentations" ?
        Dir[File.join(ENV['PM_PRESENTATIONS_DIR'], @user.id.to_s, "*")].size :
        count_for_section(object, section)

      locals = {:object => object, :section => section, :expanded => expanded, :count => count, :locals => locals}

      render :partial => 'shared/misc/section_wrap', :locals => locals unless optional && (!count || count.zero?)
    end

    def render_sections(sections, object = object_for_controller, locals = {})
      sections.map { |section| render_section(object, section, locals) }.join("\n").html_safe
    end

    def render_form_part(form, part, prefix = nil)
      render :partial => "#{edit_action}_#{part}", :locals => { :f => form } if !edit_action.blank? && !part.blank?
    end

    def render_form_parts(form, parts)
      parts = form_parts_for(parts) unless parts.is_a?(Array)
      parts.map { |part| render_form_part(form, part) }.join("\n").html_safe
    end

    def form_parts_for(section)
      [section]
    end

    def link_to_section(name, section, page = show_action, options = {}, html_options = {})
      link_to(name, options.merge(:action => page, :anchor => section), html_options)
    end

    def section_heading(name, id)
      add_to_toc(name.strip.sub(/[:]+\z/, ''), id)
      %Q{<h3 class="section_heading"><a id="#{id}" href="##{id}">#{name}</a></h3>}.html_safe
    end

    def add_to_toc(name, id)
      (@toc ||= []) << [id, name]
    end

    def render_toc
      concat(render partial: 'shared/misc/toc', locals: {toc: @toc}) unless @toc.blank?
    end

    def with_toc(&block)
      binding = block.binding
      content = capture(&block)

      render_toc
      concat(content)
    end

    def truncated(content, length = 140, options = {})
      escape = options.has_key?(:escape) ? options[:escape] : true
      simple = options.has_key?(:simple_format) ? options[:simple_format] : false

      line_re = %r{\r?\n|<br\s*/?>}o

      if length == :first_line
        # REWRITE: its called mb_chars now but since ruby supports multibyte
        # chars everywhere anyhow, we don't need it anymore
        # truncated_content = content.chars[/(.*?)(?:#{line_re})/, 1] if content =~ line_re
        truncated_content = content[/(.*?)(?:#{line_re})/, 1] if content =~ line_re
      elsif content.chars.length > length
        # REWRITE: its called mb_chars now but since ruby supports multibyte
        # chars everywhere anyhow, we don't need it anymore
        # truncated_content = content.chars[0, length].split(/(\s+)/)[0..-3].join
        truncated_content = content[0, length].split(/(\s+)/)[0..-3].join
      end

      # Truncate after the last closed link tag.
      if truncated_content && truncated_content.rindex("</a>")
        # REWRITE: its called mb_chars now but since ruby supports multibyte 
        # chars everywhere anyhow, we don't need it anymore
        # truncated_content = truncated_content.chars[0, (truncated_content.rindex("</a>") + 4)]
        truncated_content = truncated_content[0, (truncated_content.rindex("</a>") + 4)]
      end

      # Truncate if a link tag is opened but not closed afterwards
      if truncated_content && truncated_content.index("<a") && (truncated_content.index("<a") == truncated_content.length - 2)
        # Show three dots only if the text before the link tag is opened is shorter than 5 characters.
        if truncated_content.index("<a") < 5
          truncated_content = "..."
        # Truncate before the link tag is opened otherwise.
        else
          truncated_content = truncated_content[0, (truncated_content.index("<a") - 1)]
        end
      end

      if truncated_content
        content, truncated_content = h(content), h(truncated_content) if escape
        content, truncated_content = simple_format(content), simple_format(truncated_content) if simple

        render :partial => 'shared/misc/truncated', :locals => options.reverse_merge(
          :parent        => '',
          :short_title   => "#{'more'.t} (#{'Ctrl-click to expand all'.t})",
          :full_title    => "#{'less'.t} (#{'Ctrl-click to collapse all'.t})",
          :expand_text   => 'more'.t,
          :collapse_text => 'less'.t
        ).merge(
          :content           => content.html_safe,
          :truncated_content => truncated_content.html_safe
        )
      else
        content = h(content).html_safe if escape
        content = simple_format(content).html_safe if simple

        block_given? ? yield(content) : content.html_safe
      end
    end

    def suggestions_for(*field)
      options = field.extract_options!

      field_id   = field.join('_')
      results_id = "#{field_id}_suggestions"

      %Q{<div class="scriptonly"><div id="#{results_id}" class="suggestions"></div>#{javascript_tag(
        %Q{new Ajax.Autocompleter('#{field_id}', '#{results_id}', '#{url_for(options)}', { paramName: 'q', suggest: true })}
      )}</div>}.html_safe
    end

    def suggest_names_for(*field)
      options = field.extract_options!

      suggestions_for(*field << options.reverse_merge(
        :controller => 'accounts', :action => 'suggest_names'
      ))
    end

    def suggest_keywords_for(*field)
      options = field.extract_options!

      suggestions_for(*field << options.reverse_merge(
        :action => 'suggest_keywords'
      ))
    end

    def vbar
      '<span class="pale"> | </span>'.html_safe
    end

    def renest_locals(locals)
      nested_locals = locals[:locals]
      locals.delete(:locals)
      locals.merge!(nested_locals)
    end

  end

end
