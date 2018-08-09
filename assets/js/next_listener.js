/* Handle the message of what to do next */
import image_listener from './image_listener'
import constants from './constants'

function listener(event) {
  if (event.detail.correct !== undefined) {
    const correct = event.detail.correct
    const el = document.getElementById(correct ? 'correct' : 'incorrect')

    console.log("Was I correct?", correct)

    constants.activate_element(el)
  }

  if (event.detail.reroute)
    setTimeout(() => window.location.href = event.detail.path, constants.time_buffer)
  else
    image_listener(event)
}

export default listener
