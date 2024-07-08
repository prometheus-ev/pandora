import {bus} from '@wendig/lib'

const clamp = (value, min, max) => {
  let result = Math.min(value, max)
  return Math.max(result, min)
}

const delay = (f, ms) => {
  let timeout = null

  const future = (resolve, ...args) => {
    const result = f(...args)
    resolve(result)
  }

  const handler = (...args) => {
    if (timeout) {
      window.clearTimeout(timeout)
    }

    return new Promise((resolve, reject) => {
      timeout = window.setTimeout(future, ms, resolve, ...args)
    })
  }

  return handler
}

let requests = 0
let csrfToken = null
const request = (url, init = {}) => {
  init['method'] = init['method'] || 'get'
  init['headers'] = init['headers'] || {}
  init['headers']['content-type'] = 'application/json'

  const method = init['method'].toLowerCase()
  if (!['get', 'head', 'options'].includes(method)) {
    if (!csrfToken) {
      const csrf = document.querySelector("meta[name='csrf-token']")
      csrfToken = csrf.getAttribute('content')
    }
    init['headers']['X-CSRF-Token'] = csrfToken
  }

  if (init['body']) {
    if (init['headers']['content-type'] == 'application/json') {
      if (!isString(init['body'])) {
        init['body'] = JSON.stringify(init['body'])
      }
    }
  }

  requests += 1
  const promise = fetch(url, init).then(r => r.json())
  bus.emit('loading-state-change', {count: requests})
  promise.then(data => {
    requests -= 1
    bus.emit('loading-state-change', {count: requests})
  })

  return promise
}

const locale = () => {
  const url = document.location.href
  const m = url.match(/\/(en|de)\//)
  return !!m ? m[1] : 'de'
}

const isString = (value) => {
  return typeof value == 'string' || value instanceof String
}

export {
  clamp,
  locale,
  delay,
  request,
  isString
}
