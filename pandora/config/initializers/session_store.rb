if Rails.env.production?
  Rails.application.config.session_store(
    :active_record_store,
    key: '_pandora_session',
    secure: true,
    same_site: :none
  )
else
  Rails.application.config.session_store(
    :active_record_store,
    key: '_pandora_session'
  )
end
