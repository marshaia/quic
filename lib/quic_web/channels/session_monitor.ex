defmodule QuicWeb.SessionMonitor do
  alias Quic.Sessions

  def exists_session?(code) do
    session = Sessions.get_session_by_code(code)
    session !== nil && session.status === :open
  end

  def get_session(code) do
    Sessions.get_session_by_code(code)
  end

  def session_belongs_to_monitor?(code, email) do
    session = Sessions.get_session_by_code(code)
    session.monitor.email === email
  end

  def close_session(code) do
    session = get_session(code)
    Sessions.update_session(session, %{status: :closed})
    # case Sessions.update_session(session, %{status: :closed}) do
    #   {:ok, _session} -> :success
    #   {:error, _changeset} -> :error
    # end
  end
end
