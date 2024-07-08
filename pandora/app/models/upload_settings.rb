class UploadSettings < Settings
  provides_list_and_search_settings(
    :order => Upload.pconfig[:sort_fields],
    :direction => ['ASC', 'DESC', nil]
  ) {|spec|
    spec[:view][:default]     = 'gallery'
    spec[:zoom][:default]     = false
    spec[:per_page][:default] = 40
  }
end
