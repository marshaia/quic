defmodule QuicWeb.SessionMonitor do
  alias Quic.Sessions
  alias Quic.Quizzes

  # def exists_session?(code) do
  #   session = Sessions.get_open_session_by_code(code)
  #   session !== nil && session.status === :open
  # end

  # def get_session(code) do
  #   Sessions.get_open_session_by_code(code)
  # end

  def exists_session_with_id?(id) do
    try do
      Sessions.get_session!(id)
      true
    rescue
      _ -> false
    end
  end

  def exists_session_with_id_and_code?(id, code) do
    try do
      session = Sessions.get_session!(id)
      session.code === code
    rescue
      _ -> false
    end
  end

  def session_belongs_to_monitor?(id, email) do
    session = Sessions.get_session!(id)
    session.monitor.email === email
  end

  def get_session_by_id(id) do
    try do
      Sessions.get_session!(id)
    rescue
      _ -> nil
    end
  end

  # def session_belongs_to_monitor?(code, email) do
  #   session = Sessions.get_session_by_code(code)
  #   session.monitor.email === email
  # end

  def close_session(id) do
    try do
      session = Sessions.get_session!(id)
      Sessions.update_session(session, %{"status" => :closed, "end_date" => DateTime.utc_now()})

    rescue
      _ -> {:error, %{}}
    end
    # case Sessions.update_session(session, %{status: :closed}) do
    #   {:ok, _session} -> :success
    #   {:error, _changeset} -> :error
    # end
  end

  def start_session(id) do
    try do
      # alter session status to on_going
      session = Sessions.get_session!(id)
      Sessions.update_session(session, %{"status" => :on_going})

      # return first quiz question
      quiz_questions = Quizzes.get_quiz!(session.quiz.id).questions
      {:ok, Enum.at(quiz_questions, 0, nil)}

    rescue
      _ -> {:error, nil}
    end
  end

end
