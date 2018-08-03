/* handle the event that a new image is ready to be drawn */
import tinder from './tinder'
const container_el = document.getElementById('holster')

function listener(event) {
  while (container_el.firstChild) {
    container_el.removeChild(container_el.firstChild)
  }

  var i = document.createElement('img')
  i.className = "card"
  i.src = event.detail.path
  container_el.appendChild(i)
  tinder(i)
}

export default listener
