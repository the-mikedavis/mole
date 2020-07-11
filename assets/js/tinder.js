import listener from './swipe_highlighter'
import constants from './constants'

const TRIGGER_WIDTH = 60
const TRANSFORM_CUTTER = 10
const SWIPE_EVENT = constants.tinder_event_name

const mag_glass = document.getElementById('mag-glass')
let mag_glass_animation;
let mag_glass_timeout;
let ticker;

let hammertime;
// starts when you get a mole, ends when you answer
let start_time;

function on(el) {
  // allow the animation after 5 seconds
  start_animation_countdown()
  // pull in hammer.js
  hammertime = new Hammer(el, {})
  // only allow horizontal panning
  hammertime.get('pan').set({ direction: Hammer.DIRECTION_HORIZONTAL })
  // handle the event of swiping
  document.addEventListener(SWIPE_EVENT, listener)
  // where the swipe starts
  let starting_x = null

  let safe_elem = document.getElementById("safe")
  let concerned_elem = document.getElementById("concerned")

  start_time = new Date().getTime()

  // record the start of the 'delta' when starting a pan
  hammertime.on('panstart', evt => {
    clearTimeout(mag_glass_timeout)
    clearInterval(mag_glass_animation)
    reset_mag_glass()

    starting_x = evt.center.x
  })

  hammertime.on('pan', function (evt) {
    // determine the amount panned
    const delta = evt.center.x - starting_x
    // determine a good rotation amount for the image
    const rotation = delta / (screen.width / TRANSFORM_CUTTER)
    // negative is malignant (leftwards, concerned)
    // positive is benign (rightwards, safe)
    let opacity = Math.abs(delta/250) * 4 / 3
    opacity = opacity > 1.0 ? 1.0 : opacity

    if (delta < 0) {
      safe_elem.style.opacity = 0
      concerned_elem.style.opacity = opacity
    } else {
      safe_elem.style.opacity = opacity
      concerned_elem.style.opacity = 0
    }
    // rotate and translate the element for a tinder-like feel
    el.style.transform = `translate(${delta}px, 0) rotate(${rotation}deg)`
  });

  hammertime.on('panend', function (evt) {
    const delta = evt.center.x - starting_x

    start_animation_countdown()

    // emit the answer to this mole
    if (Math.abs(delta) > TRIGGER_WIDTH) {
      let time_delta = new Date().getTime() - start_time
      document.dispatchEvent(
        new CustomEvent(SWIPE_EVENT, {detail: {malignant: delta < 0, time_spent: time_delta}}))
    }

    safe_elem.style.opacity = 0
    concerned_elem.style.opacity = 0

    // reset the element back to center
    el.style.transform = `translate(0,0) rotate(0deg)`;
  });
}

function off() {
  hammertime.destroy()
  clearTimeout(mag_glass_timeout)
  clearInterval(mag_glass_animation)
  reset_mag_glass()
}

let y;
let x;
function frame() {
  if (ticker++ >= 850) {
    clearInterval(mag_glass_animation)
    reset_mag_glass()
    start_animation_countdown()
  } else if (ticker < 250) {
    y = 50 - (ticker / 10)
    mag_glass.style.top = y + 'vw'
  } else if (ticker > 300 && ticker < 500) {
    x = 50 - (ticker % 300) / 10
    mag_glass.style.left = x + '%'
  } else if (ticker > 550 && ticker < 800) {
    x = 30 + ((ticker % 550) / 10)
    y = 25 + ((ticker % 550) / 10)
    mag_glass.style.left = x + '%'
    mag_glass.style.top = y + 'vw'
  }
}

function start_animation_countdown() {
  mag_glass_timeout = setTimeout(() => {
    ticker = 0
    x = 50
    y = 50
    reset_mag_glass()
    mag_glass.classList.add('animate')
    mag_glass_animation = setInterval(frame, 5)
  }, 3000)
}

function reset_mag_glass() {
  mag_glass.style.top = '50vw'
  mag_glass.style.left = '50%'
  mag_glass.classList.remove('animate')
}

export default {on: on, off: off};
