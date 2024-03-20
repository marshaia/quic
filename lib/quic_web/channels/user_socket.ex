defmodule QuicWeb.UserSocket do
  use Phoenix.Socket

  require Logger

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels

  channel "session:*", QuicWeb.SessionChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error` or `{:error, term}`. To control the
  # response the client receives in that case, [define an error handler in the
  # websocket
  # configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"username" => username, "session" => code, "isMonitor" => isMonitor} = _params, socket, _connect_info) do
    {:ok, assign(socket, username: username, isMonitor: isMonitor, session_code: code)}
  end


  # Socket id's are topics that allow you to identify all sockets for a given user:
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #     Elixir.QuicWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket) do
    if socket.assigns.isMonitor === true do
      Logger.error("user_socket.ex says: is IS a monitor")
      "session:#{socket.assigns.session_code}:monitor:#{socket.assigns.username}"
    else
      Logger.error("user_socket.ex says: is NOT a monitor")
      "session:#{socket.assigns.session_code}:participant:#{socket.assigns.username}"
    end
  end
end
