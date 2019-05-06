import listener from './swipe_highlighter'
import constants from './constants'

const TRIGGER_WIDTH = 60
const TRANSFORM_CUTTER = 10
const SWIPE_EVENT = constants.tinder_event_name

let hammertime;
// starts when you get a mole, ends when you answer
let start_time;

function on(el) {
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
    starting_x = evt.center.x
  })

  hammertime.on('pan', function (evt) {
    // determine the amount panned
    const delta = evt.center.x - starting_x
    // determine a good rotation amount for the image
    const rotation = delta / (screen.width / TRANSFORM_CUTTER)
    // positive is malignant (rightwards, concerned)
    // negative is benign (leftwards, safe)
    let opacity = Math.abs(delta/250) * 4 / 3
    opacity = opacity > 1.0 ? 1.0 : opacity

    if (delta < 0) {
      safe_elem.style.opacity = opacity
      concerned_elem.style.opacity = 0
    } else {
      safe_elem.style.opacity = 0
      concerned_elem.style.opacity = opacity
    }
    // rotate and translate the element for a tinder-like feel
    el.style.transform = `translate(${delta}px, 0) rotate(${rotation}deg)`
  });

  hammertime.on('panend', function (evt) {
    const delta = evt.center.x - starting_x

    // emit the answer to this mole
    if (Math.abs(delta) > TRIGGER_WIDTH) {
      let time_delta = new Date().getTime() - start_time
      document.dispatchEvent(
        new CustomEvent(SWIPE_EVENT, {detail: {malignant: delta > 0, time_spent: time_delta}}))
    }

    safe_elem.style.opacity = 0
    concerned_elem.style.opacity = 0

    // reset the element back to center
    el.style.transform = `translate(0,0) rotate(0deg)`;
  });
}

function off() {
  hammertime.destroy()
}

export default {on: on, off: off};
