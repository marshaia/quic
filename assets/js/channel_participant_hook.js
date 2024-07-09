import { Socket } from "phoenix"

let channel;

export const SessionChannelParticipant = {
  mounted() {
    this.handleEvent("join_session", (obj) => {
      this.joinChannel(obj.code, obj.username)
    }),

    this.handleEvent("participant-submit-answer", (obj) => {
      this.submitAnswer(obj.code, obj.response, obj.question_id, obj.participant_id)
    }),

    this.handleEvent("participant-next-question", (obj) => {
      this.nextQuestion(obj.participant_id, obj.current_question, obj.code)
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
  },

  submitAnswer(code, response, question_id, participant_id) {
    channel.push("participant_submitted_answer", 
    {
      "participant_id": participant_id,
      "session_code" : code,
      "question_id" : question_id,
      "answer": response,
    })
  },

  nextQuestion(participant_id, current_question, code) {
    channel.push("participant_next_question", 
    {
      "participant_id": participant_id,
      "current_question": current_question,
      "code": code,
    })
  }
};