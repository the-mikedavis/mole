/* handle the event that a new image is ready to be drawn */
const image_el = document.getElementById('card')

function listener(event) {
  image_el.src = event.detail.path
}

export default listener
