import {i18n} from '@wendig/lib'
import {request} from './util'

window.i18n = i18n

i18n.translations = {}

function flatten(tree, prefix = '') {
  let result = {}

  for (const [k, v] of Object.entries(tree)) {
    if (v.constructor && v.constructor.name == 'Object') {
      Object.assign(result, flatten(v, `${prefix}${k}.`))
    } else {
      result[`${prefix}${k}`] = v
    }
  }

  return result
}

export default function() {
  const promise = request('/api/json/translations')

  promise.then((data) => {
    let t = {
      'en': {},
      'de': {}
    }

    // legacy data, using as is
    Object.assign(t['de'], data['legacy'])

    // legacy data, self-reference and use for en as well
    const en = Object.fromEntries(Object.entries(data['legacy']).map(([k, v]) => [k, k]))
    Object.assign(t['en'], en)

    // rails style data
    Object.assign(t['de'], flatten(data['rails']['de']))
    Object.assign(t['en'], flatten(data['rails']['en']))

    i18n.translations = t

    const locale = document.location.href.match(/\/(en|de)($|\/)/)[1]
    i18n.setLocale(locale)

    console.log('translations loaded')
  })

  return promise
}
