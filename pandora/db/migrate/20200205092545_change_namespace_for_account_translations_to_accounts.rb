class ChangeNamespaceForAccountTranslationsToAccounts < ActiveRecord::Migration[5.2]
  def change
    de = Language.where(:iso_639_1 => "de")
    en = Language.where(:iso_639_1 => "en")
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Translation.where(:namespace => "account").each do |ta|
            if tas = Translation.where(namespace: "accounts", tr_key: ta.tr_key, language_id: ta.language_id).first
              tas.destroy
            end
            ta.update(namespace: "accounts")
          end
        end
      end
      dir.down do
        ActiveRecord::Base.transaction do
          Translation.where(namespace: "accounts").each do |tas|
            tas.update(namespace: "account")
          end
        end
      end
    end
  end
end
