const FADE_TIME = window.feedback_time_msec || 1000  // 1 seconds

const constants = {
  tinder_event_name: 'trigger',
  image_event_name: 'new_image',
  brief_event_name: 'brief',
  next_event_name: 'answer_reply',
  activate_element: function (element) {
    element.classList.add('active')
    fade(element)
  },
  time_buffer: FADE_TIME,
  // TODO: implement if I really want this
  forms: []
}

function fade(element) {
  setTimeout(() => element.classList.remove('active'), FADE_TIME)
}

export default constants
