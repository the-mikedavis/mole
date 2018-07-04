/* handle responses about things being correct or not. Involves displaying
 * some sort of animation and then updating the image */
import image_listener from './image_listener'

function listener(event) {
  const path = event.detail.path
  const correct = event.detail.correct
  console.log("Was I correct?", correct)
  image_listener(event)
}

export default listener
