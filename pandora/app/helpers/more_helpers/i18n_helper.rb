module MoreHelpers
  module I18nHelper
    def locals_for_translated(name, field, options = {}, &block)
      object = options.delete(:object) || instance_variable_get("@#{name}")

      {
        :name       => name,
        :field      => field,
        :label      => options.delete(:label) || field.to_s.humanize,
        :suffix     => options.delete(:suffix) || ' [%s]:',
        :options    => options,
        :value_proc => block || lambda { object.send(field) }
      }
    end

    def translated(name, field, options = {}, &block)
      render :partial => 'shared/i18n/translated', :locals => {
        :tag => options.delete(:tag)
      }.merge(locals_for_translated(name, field, options, &block))
    end

    def translated_field(form, name, field, options = {}, &block)
      locals = {
        :f      => form,
        :type   => options.delete(:type) || :text_area,
        :legend => options.delete(:legend),
        :lang   => options.delete(:lang)
      }.merge(locals_for_translated(name, field, options, &block))

      partial = 'shared/i18n/translated_field'

      if locals[:lang]
        render :partial => partial, :locals => locals
      else
        ORDERED_LANGUAGES.map { |lang|
          render :partial => partial, :locals => locals.merge(:lang => lang)
        }.join("\n").html_safe
      end
    end

    def translated_fieldset(form, name, fields, options = {})
      render :partial => 'shared/i18n/translated_fieldset', :locals => {
        :f      => form,
        :name   => name,
        :fields => fields.map { |entry|
          if entry.is_a?(Array)
            entry.last.update(options)
            entry
          else
            [entry, options.dup]
          end
        }
      }
    end
  end
end
