// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/quic_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/quic_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/quic_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/quic_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
// socket.connect()

let channel;


pathname = window.location.pathname
if (pathname.startsWith("/sessions/")) {
  code = window.session_code
  session_id = window.session_id
  email = localStorage.getItem("author_email")
  joinChannel(code, email, true, session_id)
}


// Function for a User to join the channel of a Session
function joinChannel(session_code, username, isMonitor, session_id = null) {
  let socket = new Socket("/socket", {params: {session: session_code, username: username, isMonitor: isMonitor }})
  socket.connect()

  window.channel_socket = socket;

  if (session_id) {
    channel = socket.channel(
      "session:" + session_code, 
      {"username": username, "isMonitor": isMonitor, "session_id": session_id}
    )
  } else {
    channel = socket.channel(
      "session:" + session_code, 
      {"username": username, "isMonitor": isMonitor}
    )
  }

  

  channel.join()
    .receive("ok", () => {window.channel = channel})
    .receive("error", () => socket.disconnect());


  // channel.on("participant_joined_session", payload => {
  //   console.log("js server message --> " + JSON.stringify(payload))
  // });
}


// Event Listeners
// Participant Join Session Button
join_btn = document.getElementById("join-session-button")
if(join_btn) join_btn.addEventListener("click", () => {
  code = document.getElementById("join-session-input-code").value.toUpperCase()
  username = document.getElementById("join-session-input-username").value
  if (code.length === 5 && username.length > 0) joinChannel(code, username, false)
});



// Participant submits answers to question
p_submit_answer = document.getElementById("participant-submit-answer-btn")
if(p_submit_answer) p_submit_answer.addEventListener("click", () => {
  res = window.confirm("Are you sure you want to submit?")
  if(res) {
    code = localStorage.getItem("session_code")
    answer_id = sessionStorage.getItem("answer")
    question_id = sessionStorage.getItem("question")
    participant_id = localStorage.getItem("participant_token")
  
    if (answer_id) {
      joinChannel(code, participant_id, false)
      channel.push("participant_submitted_answer", 
        {
          "participant_id": participant_id,
          "session_code" : code,
          "question_id" : question_id,
          "selected_answer": answer_id,
        })
    }
  }
});

// p_send_msg_monitor = document.getElementById("participant-send-msg-monitor-btn")
// if(p_send_msg_monitor) p_send_msg_monitor.addEventListener("click", () => {
//   text = document.getElementById("participant-send-msg-monitor-input").value
//   id = localStorage.getItem("participant_token")
//   code = localStorage.getItem("session_code")
//   console.log("entrei no event clicker")
//   if (text.length > 0) {
//     joinChannel(code, id, false)
//     channel.push("participant_msg_to_monitor", 
//       {
//         "participant_id": id,
//         "session_code" : code,
//         "message": text
//       })
//   }
// });


// Author Log Out Button
log_out_btn = document.getElementById("log-out-button")
if(log_out_btn) log_out_btn.addEventListener("click", () => {
  localStorage.removeItem("author_email")
});
log_out_btn_responsive = document.getElementById("log-out-button-responsive")
if(log_out_btn_responsive) log_out_btn_responsive.addEventListener("click", () => {
  localStorage.removeItem("author_email")
});

// Monitor Starts Session
m_start_session = document.getElementById("start-session-btn")
if(m_start_session) m_start_session.addEventListener("click", () => {
  res = window.confirm("Are you sure? Once started, no more participants can join the Session!")
  if (res) {
    email = localStorage.getItem("author_email")
    session_id = window.session_id
    code = window.session_code
    
    // joinChannel(code, email, true)
    channel.push("monitor-start-session", 
      {
        "session_code" : code,
        "session_id": session_id,
        "email" : email,
      })
  }  
});

// Monitor Closes Session 
m_close_session_btn = document.getElementById("monitor-close-session-btn")
if(m_close_session_btn) m_close_session_btn.addEventListener("click", () => {
  res = window.confirm("Are you sure? A closed session cannot be opened again!")
  if (res) {
    email = localStorage.getItem("author_email")
    session_id = window.session_id
    code = window.session_code
    
    // joinChannel(code, email, true)
    channel.push("monitor-close-session", 
      {
        "session_code" : code,
        "session_id": session_id,
        "email" : email,
      })
  }  
});