class AccountSettings < Settings

  provides_list_settings :order      => Account.pconfig[:columns_for][:list],
                         :locale     => [[ORDERED_LANGUAGES, DEFAULT_LANGUAGE]],
                         :start_page => [[ApplicationController::DEFAULT_LOCATION.keys.select { |k| k.is_a?(String) }.sort]],
                         :direction => ['ASC', 'DESC', nil]

end
