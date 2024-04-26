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
      .receive("ok", (params) => {
        // window.channel = channel; 
        console.log("recebi ok: ", params);
        // this.pushEvent("joined_session", params);
      })
      .receive("error", (params) => {
        console.log("recebi erro: ", params);
        // this.pushEvent("error_joining_session", params)
        socket.disconnect();
      });
  
  
    // channel.on("test-msg", payload => {
    //   console.log("recebi test-msg!!! -> " + JSON.stringify(payload))
    // });
  },

  startSession(code, session_id, email) {
    channel.push("monitor-start-session", 
      {
        "session_code" : code,
        "session_id": session_id,
        "email" : email,
      })
      .receive("ok", () => {
        this.pushEvent("session-started")
      })
      .receive("error", () => {
        this.pushEvent("error-starting-session")
      })
  },

  closeSession(code, session_id, email) {
    channel.push("monitor-close-session", 
    {
      "session_code" : code,
      "session_id": session_id,
      "email" : email,
    })
    .receive("ok", () => {
      this.pushEvent("session-closed")
    })
    .receive("error", () => {
      this.pushEvent("error-closing-session")
    })
  }

  


};