import React from 'react'

export default class PmHeadline extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      active: false
    }
  }

  toggle(event) {
    this.setState({active: !this.state.active})
  }

  render() {
    const classes = [
      'lead',
      this.state.active ? 'pm-active' : ''
    ].join(' ')

    return(
      <div className="pm-headline">
        <h1 className="display-1">
          Prometheus
          <p className={classes}>
            Das verteilte digitale Bildarchiv für Forschung und Lehre
          </p>
        </h1>

        <button
          className="btn btn-secondary"
          onClick={(event) => this.toggle(event)}
        >toggle</button>
      </div>
    )
  }
}
