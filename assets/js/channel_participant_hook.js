import { Socket } from "phoenix"

let channel;

export const SessionChannelParticipant = {
  mounted() {
    this.handleEvent("join_session", (obj) => {
      this.joinChannel(obj.code, obj.username)
    }),

    this.handleEvent("participant-submit-answer", (obj) => {
      this.submitAnswer(obj.code, obj.response, obj.question_id, obj.participant_id)
    })
  },

  joinChannel(session_code, username) {
    let socket = new Socket("/socket", {params: {session: session_code, username: username, isMonitor: false }})
    socket.connect()
  
    window.channel_socket = socket;
  
    channel = socket.channel(
      "session:" + session_code, 
      {"username": username, "isMonitor": false}
    )
  
    channel.join()
      .receive("ok", (params) => {
        this.pushEvent("joined_session", params);
      })
      .receive("error", (params) => {
        this.pushEvent("error_joining_session", params)
        socket.disconnect();
      });
  
  
    // channel.on("test-msg", payload => {
    //   console.log("recebi test-msg!!! -> " + JSON.stringify(payload))
    // });
  },

  submitAnswer(code, response, question_id, participant_id) {
    channel.push("participant_submitted_answer", 
    {
      "participant_id": participant_id,
      "session_code" : code,
      "question_id" : question_id,
      "answer": response,
    })
    // .receive("ok", (params) => {
    //   console.log("params ---> ", JSON.stringify(params))
    //   this.pushEvent("submission_results", params)
    // })
    // .receive("error", (params) => {
    //   console.log("recebi erro: ", JSON.stringify(params))
    //   this.pushEvent("submission_results_error", params)
    // })
  }
};