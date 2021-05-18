module MoreHelpers

  module ObjectHelper

    def link_to_object(object, name = nil, options = {})
      if object.is_a?(Account) && object.anonymous?
        if object.ipuser?
          return link_to_ipuser(object, name, options)
        elsif object.dbuser?
          return link_to_dbuser(object, name, options)
        end
      end

      link_to(h(name || object), {
        :controller => object.class.controller_name,
        :action     => 'show',
        # REWRITE: this has to be an id now
        # :id         => object
        :id         => object.is_a?(Account) ? object.login : object.id
      }.merge(options))
    end

    def link_to_ipuser(object = current_user, name = nil, options = {})
      link_to(h(name || object.institution.title), {
        :controller => 'institutions', :action => 'mine'
      }.merge(options))
    end

    def link_to_dbuser(object = current_user, name = nil, options = {})
      object.open_sources.map { |source|
        link_to(h(name || source.title), {
          :controller => 'sources', :action => 'show', :id => source
        }.merge(options))
      }.join(' / ').html_safe
    end

    # translate a set of flags and return them as a list
    # @param [Hash{Symbol=>Boolean}] flags the flags to be considered
    # @return [String] the list of active flags as a list
    def translated_flag_list(flags = {})
      flags.map do |flag, active|
        active ? flag.to_s.capitalize.t : nil
      end.compact.join(', ')
    end

    # def object_status_for(*status)
    #   binding.pry
    #   status.map { |i| i.to_s.capitalize.t if i }.compact.join(', ')
    # end

    # def account_status(object)
    #   object_status_for(
    #     object.active?             && :active,
    #     object.expired?            && :expired,
    #     object.deactivated?        && :deactivated,
    #     object.expires?            && :expires,
    #     object.pending?     && :pending,
    #     object.mode.guest?         && :guest
    #   )
    # end

    # def email_status(object)
    #   object.sent? ? 'sent'.capitalize.t : 'pending'.capitalize.t
    # end

    # def announcement_status(object)
    #   object_status_for(
    #     object.expired? ? :expired :
    #     object.current? ? :current :
    #                       :upcoming
    #   )
    # end

    def access_status_to_human(status, public_view = false)
      case status
        when :readable, 'read'  then public_view ? 'Readable' : 'Publicly readable'
        when :writable, 'write' then public_view ? 'Writable' : 'Publicly writable'
        when :private,  ''      then               'Private'
        else                                       status.humanize
      end
    end

    def access_status_for(status, public_view = true)
      %Q{<span class="access_status" title="#{access_status_to_human = access_status_to_human(status, public_view).t}">#{
        image_tag("misc/access_status_#{status}.gif")
      }#{
        !box_content_id ? access_status_to_human : ''
      }</span>}.html_safe
    end

    def access_status(object, public_view = false)
      verb = if public_view
        object.writable?(current_user) ? :writable : :readable
      else
        object.publicly_writable? ? :writable : object.publicly_readable? ? :readable : :private
      end

      access_status_for(verb, public_view)
    end

    def range_summary_for(objects, name = nil)
      summary = unless objects.empty?
        first, last = objects.first_item_number, objects.last_item_number

        name &&= "#{name / (last - first + 1)} "
        range  = "#{first.loc}#{" - #{last.loc}" if first != last}"

        %Q{#{name}<strong>#{range}</strong> #{'of'.t} <strong>#{objects.count.loc}</strong>}
      else
        name &&= " #{name / 0}"
        range  = 0

        %Q{<strong>#{range}</strong>#{name}}
      end

      %Q{<span class="nowrap">#{summary}</span>}.html_safe
    end

  end

end
