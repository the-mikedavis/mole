import {Socket} from "phoenix"

let socket = null;

if (window.userToken) {
  let socket = new Socket("/socket", {params: {token: window.userToken}})

  socket.connect()

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("game:new", {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default socket
