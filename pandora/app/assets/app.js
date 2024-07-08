import i18nSetup from './js/lib/i18n.js'
import {bus, RiotPlugins, BusRiotPlugin} from '@wendig/lib'

import * as riot from 'riot'

import {setup as setupOL} from './js/lib/offensive_language'

// import Confirm from './js/components/confirm.riot'
import LiveSearch from './js/components/live_search.riot'
import LoadingIndicator from './js/components/loading_indicator.riot'
import Modal from './js/components/modal.riot'
import OlModal from './js/components/ol_modal.riot'
import SizeIndicator from './js/components/size_indicator.riot'
import WdModal from './js/components/wd_modal.riot'
import WikidataWidget from './js/components/wikidata_widget.riot'
import IndexingPage from './js/components/indexing_page.riot'

RiotPlugins.setup(riot)
riot.install(RiotPlugins.i18n)
riot.install(BusRiotPlugin)

// riot.register('pm-confirm', Confirm)
riot.register('pm-live-search', LiveSearch)
riot.register('pm-loading-indicator', LoadingIndicator)
riot.register('pm-modal', Modal)
riot.register('pm-ol-modal', OlModal)
riot.register('pm-size-indicator', SizeIndicator)
riot.register('pm-wd-modal', WdModal)
riot.register('pm-wikidata-widget', WikidataWidget)
riot.register('pm-indexing-page', IndexingPage)

i18nSetup().then((data) => {
  riot.mount('[is]')
  console.log('components mounted')

  const olClasses = [
    '.title-field',
    '.description-field',
    '.keyword-field',
    '.keywords-field',
    '.keyword_artigo-field',
    'div.image'
  ]
  setupOL(olClasses.join(', '))
  console.log('offensive language component initialized')
})
