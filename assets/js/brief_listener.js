/* handle the briefing of 5 images in the beginning */
import constants from './constants'
const container_el = document.getElementById('holster')
const IMAGE_EVENT = constants.image_event_name

function listener(event) {
  // clear out the container_el
  while (container_el.firstChild) {
    container_el.removeChild(container_el.firstChild)
  }
  var h3 = document.createElement('h3')
  h3.className = 'brief-text'
  h3.innerHTML = 'Study these moles carefully'
    //h3.innerHTML = 'These are your moles. Study them carefully before proceeding.'
  container_el.appendChild(h3)

  var p = document.createElement('p')
  p.className = 'brief-text'
  p.innerHTML = "You'll be ask to indentify them as either benign (non-cancerous) or malignant (cancerous)."
  container_el.appendChild(p)

  var imageArray = event.detail.paths
  var first = imageArray[0]

  shuffleArray(imageArray)

  for (let src of imageArray) {
    var i = document.createElement('img')
    i.className = "card brief"
    i.src = src
    container_el.appendChild(i)
  }

  var button = document.createElement('button')
  button.innerHTML = 'READY'
  button.className = 'btn btn-primary btn-block'
  button.onclick = () => {
    document.dispatchEvent(
      new CustomEvent(IMAGE_EVENT, {detail: {path: first}})
    )
  }
  container_el.appendChild(button)
}

function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
}

export default listener
