/* handle the briefing of 5 images in the beginning */
const container_el = document.getElementById('holster')

function listener(event) {
  console.log(event)
  // clear out the container_el
  while (container_el.firstChild) {
    container_el.removeChild(container_el.firstChild)
  }
  for (let src of event.detail.paths) {
    var i = document.createElement('img')
    i.className = "card brief"
    i.src = src
    container_el.appendChild(i)
  }
}

export default listener
