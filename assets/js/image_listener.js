/* handle the event that a new image is ready to be drawn */
import tinder from './tinder'
import constants from './constants'
const container_el = document.getElementById('holster')

function listener(event) {
  // we're playing the game
  if (container_el.children.length == 1) {
    const img = container_el.children[0]

    if (event.detail.correct === undefined) // no feedback condition
      nofeedback(img, event)
    else if (event.detail.motivation_text === undefined) // standard feedback
      feedback(img, event)
    else
      motivational_feedback(img, event)

  } else { // we just finished the briefing
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

    decrement_moles(event);
  }, constants.time_buffer)
}

function feedback(img, event) {
  tinder.off()

  const fbp = event.detail.feedbackpath

  // highlight the feedback text
  const feedback_txt_id = fbp.substring(8, fbp.length - 4)
  document.getElementById(feedback_txt_id).classList.add('active')

  img.classList.add('feedback-image')
  img.src = fbp

  setTimeout(() => {
    tinder.on(img)
    img.src = event.detail.path
    img.classList.remove('feedback-image')

    const feedbacks = document.getElementsByClassName('feedback')
    for (let i = 0; i < feedbacks.length; i++)
      feedbacks[i].classList.remove('active')

    decrement_moles(event)
  }, constants.time_buffer * 2)
}

function motivational_feedback(img, event) {
  tinder.off()

  const fbp = event.detail.feedbackpath
  const mp = event.detail.motivation_path
  const mt = event.detail.motivation_text
  const motivation_div = document.getElementById('motivation')
  const motivation_img = document.getElementById('motivation-img')
  const motivation_p = document.getElementById('motivation-p')
  const motivation_button = document.getElementById('motivation-button')

  // highlight the feedback text
  const feedback_txt_id = fbp.substring(8, fbp.length - 4)
  document.getElementById(feedback_txt_id).classList.add('active')

  img.classList.add('feedback-image')
  img.classList.add('feedback-image-motivational')
  img.src = fbp

  container_el.classList.add('motivate')
  motivation_div.classList.add('motivate')
  motivation_img.src = mp
  motivation_p.innerHTML = mt
  motivation_button.disabled = false;

  motivation_button.onclick = function (_event) {
    motivation_button.disabled = true;
    motivation_div.classList.remove('motivate')
    container_el.classList.remove('motivate')

    window.scrollTo(0, 0)

    tinder.on(img)
    img.src = event.detail.path
    img.classList.remove('feedback-image')
    img.classList.remove('feedback-image-motivational')

    const feedbacks = document.getElementsByClassName('feedback')
    for (let i = 0; i < feedbacks.length; i++)
      feedbacks[i].classList.remove('active')

    decrement_moles(event)
  }
}

const moles_remaining_span = document.getElementById('remaining-moles')
const case_number_span = document.getElementById('case-number')
function decrement_moles(event) {
  moles_remaining_span.innerHTML = event.detail.remaining
  case_number_span.innerHTML = random_case_number()
}

function random_case_number() {
  return Math.round(Math.random() * (10000 - 1000)) + 1000
}

export default listener
