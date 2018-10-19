/* handle the event that a new image is ready to be drawn */
import tinder from './tinder'
import constants from './constants'
const container_el = document.getElementById('holster')

function listener(event) {
  if (container_el.children.length == 1) {
    const img = container_el.children[0]
    if (event.detail.correct === undefined)
      nofeedback(img, event)
    else
      feedback(img, event)
  } else {
    while (container_el.firstChild) {
      container_el.removeChild(container_el.firstChild)
    }

    const i = document.createElement('img')
    i.className = "card"
    i.src = event.detail.path
    container_el.appendChild(i)
    tinder.on(i)
  }
}

function nofeedback(img, event) {
  tinder.off()

  img.style.opacity = '0.75';

  setTimeout(() => {
    tinder.on(img)
    img.style.opacity = '1';
    img.src = event.detail.path
  }, constants.time_buffer)
}

function feedback(img, event) {
  const correct = event.detail.correct
  const el = document.getElementById(correct ? 'correct' : 'incorrect')

  constants.activate_element(el)

  tinder.off()

  const fbp = event.detail.feedbackpath

  // highlight the feedback text
  const feedback_txt_id = fbp.substring(8, fbp.length - 4)
  document.getElementById(feedback_txt_id).classList.add('active')

  img.src = fbp

  setTimeout(() => {
    tinder.on(img)
    img.src = event.detail.path

    const feedbacks = document.getElementsByClassName('feedback')
    for (let i = 0; i < feedbacks.length; i++)
      feedbacks[i].classList.remove('active')
  }, constants.time_buffer * 3)
}

export default listener
