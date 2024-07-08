// TODO https://github.com/LeonieWeissweiler/CISTEM

import * as riot from 'riot'
import OffensiveLanguage from '../components/offensive_language.riot'
import {bus} from '@wendig/lib'

riot.register('pm-ol', OffensiveLanguage)

let jobs = []

let pageStorage = {'ol.revealed': false}

const revealed = () => {
  // return sessionStorage.getItem('ol.revealed') == 'true'
  return pageStorage['ol.revealed']
}

const toggle = (newValue) => {
  // sessionStorage.setItem('ol.revealed', newValue)
  pageStorage['ol.revealed'] = newValue
}

// wrap a regex pattern in tokenizing lookbehind and lookahead
const asToken = (pattern) => {
  const d = /^|[\s"';,\.]+|$/
  const c = /[^\s"';,\.]*/
  const str = `(?<=${d.source})${c.source}${pattern.source}${c.source}(?=${d.source})`
  return new RegExp(str, pattern.flags)
}

const replacements = [
  {pattern: asToken(/Zigeuner(?:in|innen|s)?/), replacement: 'Z***'},
  {pattern: asToken(/Mohr(?:in|innen|s|en)?/i), replacement: 'M***'},
  {pattern: asToken(/Neger(?:in|innen|s)?/i), replacement: 'N***'},
  {pattern: asToken(/Indianer(?:in|innen|s)?/i), replacement: 'I***'}
]

const replace = () => {
  for (const {type, node, m, replacement} of jobs) {
    if (type == 'text') {
      // split the text node apart
      let after = node.splitText(m.index)
      let before = node
      let tmp = after.splitText(m[0].length)
      let swap = after
      after = tmp

      // ... and replace the matched part
      const widget = document.createElement('pm-ol')
      widget.setAttribute('replacement', replacement)
      widget.setAttribute('revealed', revealed())
      swap.parentNode.replaceChild(widget, swap)
      widget.append(swap)

      riot.mount(widget)
    }

    if (type == 'title') {
      const original = node.getAttribute('title')
      node.setAttribute('title', replacement)

      console.log(original, replacement)
      const handler = () => {
        const revealed = pageStorage['ol.revealed']

        node.setAttribute('title', revealed ? original : replacement)
      }

      bus.addEventListener('ol.toggle', handler)
      handler()
    }
  }
}

const process = (node) => {
  if (node.nodeType == Node.TEXT_NODE) {
    for (const r of replacements) {
      const m = node.data.match(r.pattern)
      if (m) {
        jobs.push({node, m, replacement: r.replacement, type: 'text'})
      }
    }
  }

  if (node.nodeType == Node.ELEMENT_NODE) {
    const title = node.getAttribute('title')

    if (title) {
      for (const r of replacements) {
        const m = title.match(r.pattern)
        if (m) {
          jobs.push({node, m, replacement: r.replacement, type: 'title'})
        }
      }
    }
  }
}

const idempotencyFilter = {
  acceptNode: (node) => {
    if (node.nodeType == Node.ELEMENT_NODE) {
      if (node.tagName == 'PM-OL') {
        return NodeFilter.FILTER_REJECT
      }

      return NodeFilter.FILTER_ACCEPT
    }

    return NodeFilter.FILTER_ACCEPT
  }
}

const setup = (selector) => {
  bus.addEventListener('ol.toggle', event => toggle(event.data.reveal))

  const startedAt = new Date()

  jobs = []
  const regions = document.querySelectorAll(selector)
  for (const region of regions) {
    const walker = document.createTreeWalker(
      region,
      NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
      idempotencyFilter
    )
    while (walker.nextNode()) {
      const node = walker.currentNode
      process(node)
    }
  }
  replace()

  const doneAt = new Date()
  // console.log(`finished offensive language setup in ${doneAt - startedAt}ms`)

  document.body.classList.remove('d-none')
}

export {
  setup
}
