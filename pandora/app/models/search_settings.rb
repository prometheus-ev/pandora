class SearchSettings < Settings

  provides_list_and_search_settings(
    order: Image.pconfig[:sort_fields],
    direction: ['ASC', 'DESC', nil]
  ) { |spec|
    spec[:per_page][:default] = 10
  }

end
