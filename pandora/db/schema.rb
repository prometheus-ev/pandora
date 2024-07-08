# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_26_094044) do
  create_table "accounts", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "email"
    t.string "login"
    t.string "firstname"
    t.string "lastname"
    t.string "title"
    t.string "addressline"
    t.string "postalcode"
    t.string "city"
    t.string "country"
    t.integer "institution_id"
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.datetime "notified_at", precision: nil
    t.boolean "newsletter", default: true
    t.datetime "member_since", precision: nil
    t.string "remember_token"
    t.datetime "remember_token_expires_at", precision: nil
    t.text "notes"
    t.string "local_identifier"
    t.datetime "registered_at", precision: nil
    t.string "code"
    t.datetime "announcement_hide_time", precision: nil
    t.datetime "email_verified_at", precision: nil
    t.datetime "accepted_terms_of_use_at", precision: nil
    t.string "status"
    t.string "mode"
    t.integer "creator_id"
    t.text "about"
    t.text "about_de"
    t.integer "accepted_terms_of_use_revision"
    t.datetime "login_failed_at", precision: nil
    t.integer "failed_logins", default: 0
    t.datetime "disabled_at", precision: nil
    t.string "sha1_salt"
    t.text "research_interest"
    t.index ["code", "email"], name: "index_accounts_on_code_and_email"
    t.index ["creator_id"], name: "index_accounts_on_creator_id"
    t.index ["email"], name: "index_accounts_on_email"
    t.index ["institution_id"], name: "index_accounts_on_institution_id"
    t.index ["login", "institution_id"], name: "index_accounts_on_login_and_institution_id"
    t.index ["login"], name: "index_accounts_on_login"
    t.index ["remember_token"], name: "index_accounts_on_remember_token"
  end

  create_table "accounts_images", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "account_id"
    t.string "image_id"
    t.index ["account_id", "image_id"], name: "index_accounts_images_on_account_id_and_image_id"
  end

  create_table "accounts_institutions", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "institution_id"
    t.integer "account_id"
    t.index ["account_id", "institution_id"], name: "index_accounts_institutions_on_account_id_and_institution_id"
  end

  create_table "accounts_roles", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "account_id"
    t.integer "role_id"
    t.index ["account_id", "role_id"], name: "index_accounts_roles_on_account_id_and_role_id"
  end

  create_table "admins_sources", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "source_id"
    t.index ["account_id"], name: "index_admins_sources_on_account_id"
    t.index ["source_id"], name: "index_admins_sources_on_source_id"
  end

  create_table "announcements", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "role", default: "anyone"
    t.string "title_de"
    t.string "title_en"
    t.text "body_de"
    t.text "body_en"
  end

  create_table "boxes", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "image_id"
    t.string "ref_type"
    t.integer "owner_id"
    t.integer "collection_id"
    t.integer "position"
    t.boolean "expanded", default: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["collection_id"], name: "index_boxes_on_collection_id"
    t.index ["image_id"], name: "index_boxes_on_image_id"
    t.index ["owner_id"], name: "index_boxes_on_owner_id"
  end

  create_table "brain_busters", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "question"
    t.string "answer"
    t.string "lang", default: "en"
  end

  create_table "client_applications", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "support_url"
    t.string "callback_url"
    t.string "key"
    t.string "secret"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["key"], name: "index_client_applications_on_key", unique: true
  end

  create_table "collections", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "owner_id"
    t.text "notes"
    t.string "public_access"
    t.string "thumbnail_id"
    t.text "links"
    t.datetime "changed_at", precision: nil
    t.text "references"
    t.boolean "meta_image", default: false
    t.string "meta_image_reader"
    t.index ["owner_id"], name: "index_collections_on_owner_id"
    t.index ["thumbnail_id"], name: "index_collections_on_thumbnail_id"
    t.index ["title"], name: "index_collections_on_title"
  end

  create_table "collections_collaborators", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "collection_id"
    t.integer "account_id"
    t.index ["account_id", "collection_id"], name: "index_collections_collaborators_on_account_id_and_collection_id"
  end

  create_table "collections_images", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "collection_id"
    t.string "image_id"
    t.datetime "created_at", precision: nil
    t.index ["collection_id"], name: "collectiony"
    t.index ["image_id", "collection_id"], name: "index_collections_images_on_image_id_and_collection_id"
  end

  create_table "collections_keywords", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "keyword_id"
    t.integer "collection_id"
    t.index ["collection_id", "keyword_id"], name: "index_collections_keywords_on_collection_id_and_keyword_id"
  end

  create_table "collections_viewers", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "collection_id"
    t.integer "account_id"
    t.index ["collection_id", "account_id"], name: "index_collections_viewers_on_collection_id_and_account_id"
  end

  create_table "comments", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "collection_id"
    t.integer "parent_id"
    t.integer "author_id"
    t.text "text"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "image_id"
  end

  create_table "emails", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "from"
    t.string "reply_to"
    t.text "to"
    t.text "cc"
    t.text "bcc"
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "subject"
    t.text "body"
    t.string "subject_de"
    t.text "body_de"
    t.boolean "individual", default: false
    t.string "sent_by"
    t.string "tag", default: "Email"
    t.integer "newsletter"
    t.text "body_html"
    t.text "body_html_de"
  end

  create_table "images", primary_key: "pid", id: :string, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "source_id"
    t.integer "votes", default: 0
    t.integer "score", default: 0
    t.datetime "checked_at", precision: nil
    t.string "md5sum"
    t.index ["source_id"], name: "index_resources_on_source_id"
  end

  create_table "institutions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "description"
    t.string "addressline"
    t.string "postalcode"
    t.string "city"
    t.string "country"
    t.string "email"
    t.string "homepage"
    t.integer "contact_id"
    t.text "ipranges"
    t.integer "ipuser_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "campus_id"
    t.datetime "member_since", precision: nil
    t.text "notes"
    t.text "public_info"
    t.string "issuer"
    t.string "short"
    t.text "hostnames"
    t.index ["campus_id"], name: "index_institutions_on_campus_id"
    t.index ["contact_id"], name: "index_institutions_on_contact_id"
    t.index ["ipuser_id"], name: "index_institutions_on_ipuser_id"
    t.index ["name"], name: "index_institutions_on_name"
  end

  create_table "keywords", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title_de"
    t.string "title"
    t.index ["title", "title_de"], name: "titly"
  end

  create_table "keywords_sources", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "keyword_id"
    t.integer "source_id"
    t.index ["keyword_id", "source_id"], name: "index_keywords_sources_on_keyword_id_and_source_id"
  end

  create_table "keywords_uploads", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "keyword_id"
    t.integer "upload_id"
    t.index ["keyword_id", "upload_id"], name: "index_keywords_uploads_on_keyword_id_and_upload_id"
  end

  create_table "license_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.integer "amount"
    t.index ["title"], name: "index_license_types_on_title"
  end

  create_table "licenses", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "license_type_id"
    t.integer "institution_id"
    t.integer "account_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.datetime "terminates_at", precision: nil
    t.float "amount"
    t.datetime "valid_from", precision: nil
    t.datetime "paid_from", precision: nil
    t.index ["account_id"], name: "index_licenses_on_account_id"
    t.index ["institution_id"], name: "index_licenses_on_institution_id"
    t.index ["license_type_id"], name: "index_licenses_on_license_type_id"
  end

  create_table "locations", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "owner_id"
    t.string "image_id"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "oauth_nonces", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "nonce"
    t.integer "timestamp"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["nonce", "timestamp"], name: "index_oauth_nonces_on_nonce_and_timestamp", unique: true
  end

  create_table "oauth_tokens", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "type"
    t.integer "client_application_id"
    t.string "token"
    t.string "secret"
    t.string "callback_url"
    t.string "verifier"
    t.datetime "authorized_at", precision: nil
    t.datetime "invalidated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["token"], name: "index_oauth_tokens_on_token", unique: true
  end

  create_table "payment_transactions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "price"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "client_id"
    t.string "status"
    t.text "cb_params"
    t.string "service"
    t.string "pp_transaction_id"
  end

  create_table "rate_limits", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "key"
    t.string "timestamp"
    t.integer "count", default: 0
    t.index ["key", "timestamp"], name: "index_rate_limits_on_key_and_timestamp"
  end

  create_table "roles", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.index ["title"], name: "index_roles_on_title"
  end

  create_table "schema_info", id: false, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "version"
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "session_id"
    t.datetime "updated_at", precision: nil
    t.text "data", size: :long
    t.index ["session_id"], name: "index_sessions_on_session_id"
  end

  create_table "settings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "type"
    t.boolean "zoom"
    t.integer "per_page"
    t.integer "list_per_page"
    t.string "order"
    t.string "list_order"
    t.string "direction"
    t.string "list_direction"
    t.string "view"
    t.string "locale"
    t.string "start_page"
    t.boolean "facets"
    t.integer "facets_limit"
    t.index ["type", "user_id"], name: "index_settings_on_type_and_user_id"
  end

  create_table "short_urls", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.text "url"
    t.string "token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "sources", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "name"
    t.string "kind"
    t.integer "type", default: 0
    t.integer "institution_id"
    t.integer "contact_id"
    t.integer "admin_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "description"
    t.text "url"
    t.string "email"
    t.text "technical_info"
    t.integer "record_count", default: 0
    t.datetime "loaded_at", precision: nil
    t.integer "dbuser_id"
    t.float "rating"
    t.text "description_de"
    t.text "technical_info_de"
    t.integer "owner_id"
    t.boolean "is_time_searchable", default: false
    t.integer "quota", default: 1000
    t.string "owner_type"
    t.boolean "can_exploit_rights"
    t.boolean "auto_approve_records"
    t.integer "object_count", default: 0
    t.index ["admin_id"], name: "index_sources_on_admin_id"
    t.index ["contact_id"], name: "index_sources_on_contact_id"
    t.index ["dbuser_id"], name: "index_sources_on_dbuser_id"
    t.index ["institution_id"], name: "index_sources_on_institution_id"
    t.index ["name"], name: "index_sources_on_name"
    t.index ["owner_id"], name: "index_sources_on_owner_id"
    t.index ["owner_type", "owner_id"], name: "index_sources_on_owner_type_and_owner_id"
  end

  create_table "sum_stats", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.integer "day"
    t.integer "sessions_campus", default: 0
    t.integer "sessions_personalized", default: 0
    t.integer "searches_campus", default: 0
    t.integer "searches_personalized", default: 0
    t.integer "downloads_campus", default: 0
    t.integer "downloads_personalized", default: 0
    t.integer "hits_campus", default: 0
    t.integer "hits_personalized", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "institution_id"
    t.index ["institution_id", "year", "month", "day"], name: "index_sum_stats_on_institution_id_and_year_and_month_and_day"
    t.index ["year", "month", "day"], name: "index_sum_stats_on_year_and_month_and_day"
  end

  create_table "uploads", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "parent_id"
    t.string "image_id"
    t.boolean "approved_record", default: false
    t.string "filename_extension"
    t.float "file_size"
    t.string "artist"
    t.text "title", default: ""
    t.string "resource_title"
    t.string "location"
    t.float "latitude"
    t.float "longitude"
    t.text "discoveryplace"
    t.string "genre"
    t.string "material"
    t.text "description"
    t.string "date"
    t.text "credits"
    t.string "rights_work"
    t.string "rights_reproduction"
    t.text "addition"
    t.text "annotation"
    t.string "iconography"
    t.string "institution"
    t.string "inventory_no"
    t.text "origin"
    t.string "other_persons"
    t.string "photographer"
    t.string "size"
    t.string "subtitle"
    t.text "text"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "license"
    t.bigint "database_id"
    t.string "isbn"
    t.string "keyword"
    t.string "technique"
    t.string "index_record_id"
    t.string "epoch"
    t.string "signature"
    t.boolean "add_to_index"
    t.index ["database_id"], name: "index_uploads_on_database_id"
    t.index ["image_id"], name: "index_uploads_on_image_id"
    t.index ["parent_id"], name: "index_uploads_on_parent_id"
  end

  create_table "user_metadata", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "pid"
    t.text "updates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pid"], name: "identy"
  end

end
