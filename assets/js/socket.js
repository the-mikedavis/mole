import {Socket} from "phoenix"
import constants from './constants'
import brief_listener from './brief_listener'
import image_listener from './image_listener'
import next_listener from './next_listener'

let socket = null

const BRIEF_EVENT = constants.brief_event_name
const IMAGE_EVENT = constants.image_event_name
const NEXT_EVENT = constants.next_event_name

if (window.userToken) {
  let socket = new Socket("/socket", {params: {token: window.userToken}})

  socket.connect()

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("game:new", {})
  channel.join()
    .receive("ok", resp => {
      document.dispatchEvent(new CustomEvent(BRIEF_EVENT, {detail: resp}))
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

  document.addEventListener(constants.tinder_event_name, (event) => {
    channel.push("answer", event.detail)
      .receive("ok", resp => {
        document.dispatchEvent(new CustomEvent(NEXT_EVENT, {detail: resp}))
      })
  })

  document.addEventListener(BRIEF_EVENT, brief_listener)
  document.addEventListener(IMAGE_EVENT, image_listener)
  document.addEventListener(NEXT_EVENT, next_listener)
}

export default socket
