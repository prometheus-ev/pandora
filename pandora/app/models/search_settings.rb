class SearchSettings < Settings
  provides_list_and_search_settings(
    order: Indexing::IndexFields.sort,
    direction: ['ASC', 'DESC', nil]
  ) {|spec|
    spec[:per_page][:default] = 10
  }
end
