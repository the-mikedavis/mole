/* Handle the message of what to do next */
import image_listener from './image_listener'

function listener(event) {
  if (event.detail.reroute) {
    // reroute to the specified path
    window.location.href = event.detail.path
  } else
    // move on to the next image
    const path = event.detail.path
    const correct = event.detail.correct
    const el = document.getElementById(correct ? 'correct' : 'incorrect')

    console.log("Was I correct?", correct)

    image_listener(event)
  }
}

export default listener
