defmodule QuicWeb.SessionMonitor do

  alias Quic.Participants
  alias Quic.Sessions

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
  end

  def start_session(id) do
    try do
      # alter session status to on_going and current_question to 1
      session = Sessions.get_session!(id)
      Sessions.update_session(session, %{"status" => :on_going, "current_question" => 1})

      # return first quiz question
      # quiz_questions = Quizzes.get_quiz_questions!(session.quiz.id)
      {:ok, Enum.find(session.quiz.questions, nil, fn q -> q.position === 1 end)}
    rescue
      _ -> {:error, nil}
    end
  end

  require Logger
  def next_question(id) do
    try do
      session = Sessions.get_session!(id)
      num_quiz_questions = Enum.count(session.quiz.questions)

      if session.current_question < num_quiz_questions do
        # increment session current_question
        {:ok, session} = Sessions.update_session(session, %{"current_question" => session.current_question + 1})
        # increment Participant's current_questions
        if Enum.count(session.participants) > 0 do
          Enum.each(session.participants, fn p -> (if p.current_question < session.current_question, do: Participants.update_participant(p, %{"current_question" => session.current_question - 1})) end)
        end

        # return next question
        # quiz_questions = Quizzes.get_quiz_questions!(session.quiz.id)
        {:ok, Enum.find(session.quiz.questions, nil, fn q -> q.position === session.current_question end)}
      else
        {:error, nil}
      end
    rescue
      _ -> {:error, nil}
    end
  end

end
