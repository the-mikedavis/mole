/* handle responses about things being correct or not. Involves displaying
 * some sort of animation and then updating the image */
import image_listener from './image_listener'
import constants from './constants'

function listener(event) {
  const path = event.detail.path
  const correct = event.detail.correct
  const el = document.getElementById(correct ? 'correct' : 'incorrect')

  console.log("Was I correct?", correct)

  constants.activate_element(el)

  image_listener(event)
}

export default listener
