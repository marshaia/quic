defmodule Quic.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false
  alias Quic.Repo

  #alias Quic.Accounts.Author
  alias Quic.Sessions.Session
  alias Quic.Participants.Participant

  alias Quic.Sessions.CodeGenerator
  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  require Logger
  def list_all_author_sessions(id) do
    # author = Repo.get(Author, id)
    #   |> Repo.preload([sessions: from(s in Session, group_by: [s.inserted_at, s.id], order_by: [desc: s.updated_at])])
    #   |> Repo.preload(sessions: :quiz) #|> Repo.preload(sessions: :participants)

    #   Logger.error("\n\nsessions map: #{inspect Enum.group_by(author.sessions, &(&1.inserted_at))}\n\n")

    # author.sessions
    query = from s in Session, preload: :quiz,
      where: s.monitor_id == ^id,
      select: %{date: fragment("date(?)", s.inserted_at), entity: s},
      order_by: fragment("date(?)", s.inserted_at)

    results = Repo.all(query)
    grouped_results = Enum.group_by(results, &(&1.date))

    grouped_results
    |> Enum.map(fn {date, entries} ->
      sessions = Enum.map(entries, &(&1.entity))
      %{date: date, sessions: sessions}
    end)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id) |> Repo.preload(:monitor) |> Repo.preload(quiz: :questions) |> Repo.preload([participants: from(p in Participant, order_by: [desc: p.total_points])])

  def get_session_participants(id) do
    session = Repo.get!(Session, id) |> Repo.preload([participants: from(p in Participant, order_by: [desc: p.total_points])]) |> Repo.preload(participants: [answers: :question])
    session.participants
  end

  def get_session_quiz(id) do
    session = Repo.get!(Session, id) |> Repo.preload(quiz: [questions: :answers])
    session.quiz
  end

  def get_open_session_by_code(code) do
    Repo.get_by(Session, code: code, status: :open) |> Repo.preload(:participants)
  end

  def get_open_sessions() do
    query = from s in "sessions", where: s.status == "open", select: s.code
    Repo.all(query)
  end

  def is_session_open?(code) do
    try do
      Repo.get_by!(Session, code: code, status: :open)
      true
    rescue
      _ -> false
    end
  end


  def calculate_quiz_question_accuracy(session_id, question_position) do
    participants = get_session_participants(session_id)
    %{correct: correct, incorrect: incorrect} = Enum.reduce(participants, %{correct: 0, incorrect: 0},
      fn p, acc ->
        participant_answer = Enum.find(p.answers, nil, fn a -> a.question.position === question_position end)
        case participant_answer do
          nil -> %{correct: acc.correct, incorrect: acc.incorrect + 1}
          answer -> if answer.result === :correct, do: %{correct: acc.correct + 1, incorrect: acc.incorrect}, else: %{correct: acc.correct, incorrect: acc.incorrect + 1}
        end
      end)

      if correct + incorrect === 0, do: 0, else: Float.round((correct / (correct + incorrect)) * 100, 2)
  end

  def calculate_quiz_question_stats(session_id, question_position) do
    participants = get_session_participants(session_id)
    %{correct: correct, incorrect: incorrect, null: null} = Enum.reduce(participants, %{correct: 0, incorrect: 0, null: 0},
      fn p, acc ->
        participant_answer = Enum.find(p.answers, nil, fn a -> a.question.position === question_position end)
        case participant_answer do
          nil -> %{correct: acc.correct, incorrect: acc.incorrect, null: acc.null + 1}
          answer -> if answer.result === :correct, do: %{correct: acc.correct + 1, incorrect: acc.incorrect, null: acc.null}, else: %{correct: acc.correct, incorrect: acc.incorrect + 1, null: acc.null}
        end
      end)
    [correct, incorrect, null]
  end


  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(attrs \\ %{}, monitor, quiz) do
    attrs = Map.put(attrs, "code", generate_valid_code())
            |> Map.put("status", :open)
            |> Map.put("start_date", DateTime.utc_now())
            |> Map.put("current_question", 0)

    %Session{}
    |> Session.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:monitor, monitor)
    |> Ecto.Changeset.put_assoc(:quiz, quiz)
    |> Repo.insert()
  end

  def generate_valid_code() do
    code = CodeGenerator.generate_code(5)

    case get_open_sessions() do
      [] -> code
      codes ->
        if Enum.any?(codes, fn c -> c === code end) do
          generate_valid_code()
        else
          code
        end
    end

  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end
end
