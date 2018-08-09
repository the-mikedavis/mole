/* handle the event that a new image is ready to be drawn */
import tinder from './tinder'
import constants from './constants'
const container_el = document.getElementById('holster')

function listener(event) {
  if (container_el.children.length == 1) {
    var i = container_el.children[0]
    tinder.off()

    i.style.opacity = '0.75';

    setTimeout(() => {
      tinder.on(i)
      i.style.opacity = '1';
      i.src = event.detail.path
    }, constants.time_buffer)

  } else {
    while (container_el.firstChild) {
      container_el.removeChild(container_el.firstChild)
    }

    var i = document.createElement('img')
    i.className = "card"
    i.src = event.detail.path
    container_el.appendChild(i)
    tinder.on(i)
  }
}

export default listener
