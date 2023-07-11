class AddTranslationToKeywords < ActiveRecord::Migration[5.2]
  def change
    change_table :keywords do |t|
      t.remove_index column: ['title']

      t.rename :title, :title_de
      t.string :title

      t.index ['title', 'title_de'], name: 'titly'
    end

    # we load the legacy translations and try to find a match for each keyword
    # and we also strip the values
    en_de = I18n::Backend::Pandora.cache
    de_en = en_de.invert
    Keyword.find_each do |keyword|
      updates = {}

      if keyword.title_de.present?
        updates[:title_de] = keyword.title_de.strip

        if keyword.title.blank?
          translation = de_en[updates[:title_de]]
          if translation.present?
            updates[:title] = translation
          end
        end
      end

      if keyword.title.present?
        updates[:title] = keyword.title.strip

        if keyword.title_de.blank?
          translation = de_en[updates[:title]]
          if translation.present?
            updates[:title_de] = translation
          end
        end
      end

      unless updates.empty?
        keyword.update(updates)
      end
    end
  end
end
