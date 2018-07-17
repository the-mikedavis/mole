/* Sets up form slots for all inputs that need it */
import constants from './constants'
import form_slot from './form_slot'

function give_form_feedback() {
  for (let form of constants.forms) {
    let el = document.querySelector(form.selector)
    if (el) form_slot(el, form.endpoint, form.func)
  }
}

export default give_form_feedback
