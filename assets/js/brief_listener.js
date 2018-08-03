/* handle the briefing of 5 images in the beginning */
import constants from './constants'
const container_el = document.getElementById('holster')
const IMAGE_EVENT = constants.image_event_name

function listener(event) {
  // clear out the container_el
  while (container_el.firstChild) {
    container_el.removeChild(container_el.firstChild)
  }
  var p = document.createElement('p')
  p.innerHTML = 'These are your moles. Study them carefully before proceeding.'
  container_el.appendChild(p)

  for (let src of event.detail.paths) {
    var i = document.createElement('img')
    i.className = "card brief"
    i.src = src
    container_el.appendChild(i)
  }

  var button = document.createElement('button')
  button.innerHTML = 'READY'
  button.onclick = () => {
    document.dispatchEvent(
      new CustomEvent(IMAGE_EVENT, {detail: {path: event.detail.paths[0]}})
    )
  }
  container_el.appendChild(button)
}


export default listener
