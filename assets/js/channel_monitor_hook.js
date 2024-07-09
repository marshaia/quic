import { Socket } from "phoenix"

let channel;

export const SessionChannelMonitor = {
  mounted() {
    this.handleEvent("join_session", (obj) => {
      this.joinChannel(obj.code, obj.email, obj.session_id)
    }),

    this.handleEvent("start_session", (obj) => {
      this.startSession(obj.code, obj.session_id, obj.email)
    }),

    this.handleEvent("close_session", (obj) => {
      this.closeSession(obj.code, obj.session_id, obj.email)
    }),

    this.handleEvent("next_question", (obj) => {
      this.nextQuestion(obj.code, obj.session_id, obj.email)
    })
  },

  joinChannel(session_code, username, session_id) {
    let socket = new Socket("/socket", {params: {session: session_code, username: username, isMonitor: true }})
    socket.connect()
  
    window.channel_socket = socket;
  
    channel = socket.channel(
      "session:" + session_code, 
      {"username": username, "isMonitor": true, "session_id": session_id}
    )
    
    channel.join()
      .receive("error", () => {
        socket.disconnect();
      });
  },

  startSession(code, session_id, email) {
    channel.push("monitor-start-session", 
      {
        "session_code": code,
        "session_id": session_id,
        "email": email,
      })
  },

  closeSession(code, session_id, email) {
    channel.push("monitor-close-session", 
    {
      "session_code": code,
      "session_id": session_id,
      "email": email,
    })
  },

  nextQuestion(code, session_id, email) {
    channel.push("monitor-next-question", 
    {
      "session_code": code,
      "session_id": session_id,
      "email": email,
    })
  }
};