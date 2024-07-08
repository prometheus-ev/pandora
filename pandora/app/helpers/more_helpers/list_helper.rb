module MoreHelpers
  module ListHelper
    def pagination_for(*args)
      render :partial => 'shared/list/pagination', :locals => {:args => args}
    end

    def list_sort_links_for(*args)
      render :partial => 'shared/list/sort_links', :locals => {:args => args}
    end

    def list_sort_links(args = ['Title', 'Updated at'])
      args = args.list_columns if args.is_a?(Class)
      list_sort_links_for *@sortable_fields || args
    end

    def page_form(url = true, &block)
      if id = box_content_id
        # REWRITE: remote_form_for is gone, we'll have to write this ourselves
        # TODO: the resulting pagination can't work like this, fix it :)
        # remote_form_for(:box,
        #   :url => {}, :update => id, :complete => "Pandora.Behaviour.apply(true, '#{id}')",
        #   :html => { :class => 'page_form' }, &block)
        form_for(
          :box,
          url: {box_id: params[:box_id]},
          data: {update: id},
          complete: "Pandora.Behaviour.apply(true, '#{id}')",
          html: {:class => 'page_form'},
          remote: true,
          &block
        )
      else
        # REWRITE: in fact, we have to stay on the same url always if nothing
        # else is specified
        # form_tag(url ? params.slice(*%w[controller action]).merge(:id => nil) : {}, {
        form_tag({}, {method: 'get', class: 'page_form'}, &block)
      end
    end

    def list_search_for(klass, options = {})
      render :partial => 'shared/list/search', :locals => {:klass => klass, :options => options.merge(:page => nil)}
    end

    def list_search_link_for(field, term, options = {})
      term, value = term if term.is_a?(Array)

      placeholder = options.delete(:placeholder)

      options[:action] ||= action_name
      options.update(:field => field, :value => term, :page => nil)

      term.blank? ? placeholder : link_to(
        h(value || term),
        options,
        :title => "Filter by this #{field.to_s.singularize}".t
      )
    end

    def list_search_links_for(field, terms, options = {})
      separator = options.delete(:separator) || ', '
      terms.map{|term| list_search_link_for(field, term, options.dup)}.compact.join(separator).html_safe
    end

    def render_list_for(klass, options = {})
      render :partial => 'shared/list/list', :locals => options.merge(:klass => klass)
    end

    def box_content_id(id = nil)
      id ||= params[:box_id]
      "#{id}-content" if id
    end
  end
end
