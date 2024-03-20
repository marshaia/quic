defmodule QuicWeb.SessionMonitor do
  alias Quic.Sessions

  def exists_session?(code) do
    session = Sessions.get_session_by_code(code)
    session !== nil && session.status === :open
  end

  def get_session(code) do
    Sessions.get_session_by_code(code)
  end

  def session_belongs_to_monitor?(session, username) do
    session.monitor.email === username
  end
end
