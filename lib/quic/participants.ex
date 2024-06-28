defmodule Quic.Participants do
  @moduledoc """
  The Participants context.
  """

  import Ecto.Query, warn: false
  alias Quic.Participants.Participant
  alias Quic.{Repo, Sessions, ParticipantAnswers}


  @doc """
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants do
    Repo.all(Participant)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id) |> Repo.preload(:session) |> Repo.preload(:answers)

  def get_participant_session_code!(id)  do
    try do
      participant = Repo.get!(Participant, id) |> Repo.preload(:session)
      participant.session.code
    rescue
      _ -> nil
    end
  end

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}, session) do
    attrs = attrs
        |> Map.put("total_points", 0)
        |> Map.put("current_question", 0)

    %Participant{}
    |> Participant.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:session, session)
    |> Repo.insert()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{data: %Participant{}}

  """
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end

  def change_participant_validate(%Participant{} = participant, attrs \\ %{}, code) do
    Participant.changeset_validate(participant, attrs, code)
  end


  # Utils
  def channel_create_participant(session, username) do
    participant = %{"name" => username}
    create_participant(participant, session)
  end

  def get_participant_name(id) do
    get_participant!(id).name
  end

  def participant_already_in_session?(id, session_code) do
    case get_participant_session_code!(id) do
      nil ->  false
      code -> session_code === code
    end
  end

  def update_participant_current_question(participant_id) do
    participant = get_participant!(participant_id)
    participant |> update_participant(%{"current_question" => participant.current_question + 1})
  end

  def update_participant_results(participant_id, question_id, results) do
    participant = get_participant!(participant_id)
    question = Enum.find(participant.session.quiz.questions, fn q -> q.id === question_id end)
    participant_answer = Enum.find(participant.answers, nil, fn a -> a.question_id === question_id end)

    case results[:result] do
      :correct ->
        participant |> update_participant(%{"total_points" => participant.total_points + question.points})
        ParticipantAnswers.update_participant_answer(participant_answer, %{"result" => :correct})
      result ->
        ParticipantAnswers.update_participant_answer(participant_answer, %{"result" => result, "error_reason" => results[:error_reason]})
    end
  end

  def get_participant_next_question(participant_id, current_question) do
    participant = get_participant!(participant_id)
    session = Sessions.get_session!(participant.session.id)
    quiz_questions = session.quiz.questions

    if Enum.count(quiz_questions) === current_question do
      {:error_max_questions, participant}
    else
      if current_question >= 1 && current_question < Enum.count(quiz_questions) do
        next_question = Enum.find(quiz_questions, nil, fn q -> q.position === current_question + 1 end)
        if next_question !== nil, do: {:ok, next_question}, else: {:error_invalid_question, participant}
      else
        {:error, participant}
      end
    end
  end
end
