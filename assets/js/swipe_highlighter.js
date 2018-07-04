/* Handle a swipe event from `tinder.js` */
import image_listener from './image_listener'

const FADE_TIME = 3000  // 3 seconds
const type_tell = document.getElementById('type-tell')
const benign_el = type_tell.firstChild
const malignant_el = type_tell.lastChild

function listener(event) {
  // malignant = true, benign = false
  activate(event.detail ? malignant_el : benign_el)
}

function activate(element) {
  element.classList.add('active')
  fade(element)
}

function fade(element) {
  setTimeout(() => element.classList.remove('active'), FADE_TIME)
}

export default listener
