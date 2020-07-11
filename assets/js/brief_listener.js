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

  for (let i = 0; i < imageArray.length / 4; i++) {
    var p = document.createElement('p')
    p.className = "subjectname"
    p.innerText = "Subject #" + (i + 1)
    container_el.appendChild(p)

    for (let j = 0; j < imageArray.length / 3; j++) {
      var img = document.createElement('img')
      img.className = "card brief"
      img.src = imageArray[4 * i + j]
      container_el.appendChild(img)
    }
  }

  document.getElementById('ready').onclick = () => {
    ready_up(new CustomEvent(IMAGE_EVENT, {detail: {path: first}}))
  }
}

export default listener
