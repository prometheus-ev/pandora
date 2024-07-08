class WikidataController < ApplicationController
  def index
    term = params[:term]

    response = Faraday.get(
      'https://www.wikidata.org/w/api.php?',
      action: 'wbsearchentities',
      search: term,
      format: 'json',
      language: 'en',
      # language: I18n.locale,
      uselang: I18n.locale
      # type: 'item'
    )

    render json: response.body, status: response.status
  end
end
