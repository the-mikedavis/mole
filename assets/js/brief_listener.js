/* handle the briefing of 5 images in the beginning */
import constants from './constants'
import ready_up from './ready_up_event'
const container_el = document.getElementById('holster')
const IMAGE_EVENT = constants.image_event_name

function listener(event) {
  // clear out the container_el
  while (container_el.firstChild) {
    container_el.removeChild(container_el.firstChild)
  }

  var imageArray = event.detail.paths
  var first = imageArray[0]

  shuffleArray(imageArray)

  for (let src of imageArray) {
    var i = document.createElement('img')
    i.className = "card brief"
    i.src = src
    container_el.appendChild(i)
  }

  document.getElementById('ready').onclick = () => {
    ready_up(new CustomEvent(IMAGE_EVENT, {detail: {path: first}}))
  }
}

function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
}

export default listener
