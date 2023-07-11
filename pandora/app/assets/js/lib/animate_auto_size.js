import {delay} from './util'

export default class AnimateHeightSize {
  static setup() {
    const elements = document.querySelectorAll('.animate-width-auto')
    for (const e of elements) {
      new AnimateHeightSize(e)
    }
  }

  constructor(element) {
    this.onResize = this.onResize.bind(this)

    const delayedOnResize = delay(this.onResize, 1000)

    this.observer = new ResizeObserver(delayedOnResize)
    this.element = element
    this.observer.observe(element)
  }

  onResize(entries) {

    console.log(entries)
    for (const e of entries) {

      console.log(e)
      console.log(e.target)
      console.log(e.target.clientWidth)
    }
  }

  // constructor(container, element, dimension = 'height') {
  //   this.container = container
  //   this.element = element
  //   this.dimension = dimension
  // }

  // toggle() {
  //   // cache transition value
  //   const transition = window.getComputedStyle(this.container).transition
  //   const currentDisplay = this.element.style.display
  //   const nextDisplay = (currentDisplay == 'none' ? null : 'none')
  //   console.log(currentDisplay, nextDisplay, transition)

  //   // remove content without transition and read resulting this.container height
  //   const currentHeight = this.container.clientHeight
  //   this.container.style.transition = null
  //   this.container.style.height = 'auto'
  //   this.element.style.display = nextDisplay
  //   const nextHeight = this.container.clientHeight
  //   if (nextDisplay == 'none') {
  //     // we are removing content, so we keep it around until after the transition
  //     this.element.style.display = currentDisplay
  //   }

  //   // reinstate the transition and apply the explicit heigt read from above
  //   this.container.style.height = currentHeight + 'px'
  //   this.container.style.overflowY = 'clip'
  //   this.container.style.overflowX = 'visible'
  //   getComputedStyle(this.element).height
  //   this.container.style.transition = transition
  //   this.container.style.height = nextHeight + 'px'

  //   this.container.addEventListener('transitionend', event => {
  //     if (event.propertyName == 'height') {
  //       // apply the final state for the added/removed content and revert
  //       // temporary style changes
  //       this.element.style.display = nextDisplay
  //       this.container.style.overflowY = ''
  //       this.container.style.height = 'auto'
  //     }
  //   })
  // }

  // overFlowDim() {
  //   return {'width': 'overflowX', 'height': 'overflowY'}[this.dimension]
  // }

  // overFlowDim() {
  //   return {'width': 'overflowX', 'height': 'overflowY'}[this.dimension]
  // }
}
