import listener from './swipe_highlighter'
import constants from './constants'

const TRIGGER_WIDTH = 60
const TRANSFORM_CUTTER = 10
const SWIPE_EVENT = constants.tinder_event_name

function tinder (el) {
  // pull in hammer.js
  const hammertime = new Hammer(el, {})
  // only allow horizontal panning
  hammertime.get('pan').set({ direction: Hammer.DIRECTION_HORIZONTAL })
  // handle the event of swiping
  document.addEventListener(SWIPE_EVENT, listener)
  // where the swipe starts
  let starting_x = null

  // record the start of the 'delta' when starting a pan
  hammertime.on('panstart', evt => starting_x = evt.center.x)

  hammertime.on('pan', function (evt) {
    // determine the amount panned
    const delta = evt.center.x - starting_x
    // determine a good rotation amount for the image
    const rotation = delta / (screen.width / TRANSFORM_CUTTER)
    // rotate and translate the element for a tinder-like feel
    el.style.transform = `translate(${delta}px, 0) rotate(${rotation}deg)`
  });

  hammertime.on('panend', function (evt) {
    const delta = evt.center.x - starting_x

    // emit a boolean for which direction was swiped
    if (Math.abs(delta) > TRIGGER_WIDTH)
      document.dispatchEvent(new CustomEvent(SWIPE_EVENT, {detail: delta > 0}))

    // reset the element back to center
    el.style.transform = `translate(0,0) rotate(0deg)`;
  });
}

export default tinder;
