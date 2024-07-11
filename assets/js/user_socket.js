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
}