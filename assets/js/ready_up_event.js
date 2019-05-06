function ready_up(event) {
  // document.getElementById('type-tell').style.display = 'block'

  document.getElementById('holster').classList.remove('briefing')
  document.getElementById('describe').classList.remove('briefing')
  document.getElementById('ready').classList.remove('briefing')
  document.getElementById('progress').classList.add('track')

  document.dispatchEvent(event)
}

export default ready_up
