const FADE_TIME = 3000  // 3 seconds

const constants = {
  tinder_event_name: 'trigger',
  image_event_name: 'new_image',
  next_event_name: 'answer_reply',
  activate_element: function (element) {
    element.classList.add('active')
    fade(element)
  },
  // TODO: implement if I really want this
  forms: []
}

function fade(element) {
  setTimeout(() => element.classList.remove('active'), FADE_TIME)
}

export default constants
