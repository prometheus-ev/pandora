class CollectionSettings < Settings
  provides_list_and_search_settings(
    Settings::LIST_SETTINGS.inject({}) { |h, (k, v)| h[:"list_#{k}"] = v; h }.merge(
      :list_order => ['title', 'updated_at', 'owner'].freeze,
      :order      => %w[insertion_order] + Image.pconfig[:sort_fields] - %w[relevance]
    ).merge(direction: ['ASC', 'DESC', nil])
  ) { |spec|
    spec[:view][:default]     = 'gallery'
    spec[:zoom][:default]     = false
    spec[:per_page][:default] = 30
  }
end
