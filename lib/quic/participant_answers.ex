defmodule Quic.ParticipantAnswers do
  @moduledoc """
  The ParticipantAnswers context.
  """

  import Ecto.Query, warn: false
  alias Quic.Questions
  alias Quic.Repo

  alias Quic.ParticipantAnswers.ParticipantAnswer
  alias Quic.Participants

  @doc """
  Returns the list of participant_answers.

  ## Examples

      iex> list_participant_answers()
      [%ParticipantAnswer{}, ...]

  """
  def list_participant_answers do
    Repo.all(ParticipantAnswer)
  end

  @doc """
  Gets a single participant_answer.

  Raises `Ecto.NoResultsError` if the Participant answer does not exist.

  ## Examples

      iex> get_participant_answer!(123)
      %ParticipantAnswer{}

      iex> get_participant_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant_answer!(id), do: Repo.get!(ParticipantAnswer, id) |> Repo.preload(question: :answers)

  @doc """
  Creates a participant_answer.

  ## Examples

      iex> create_participant_answer(%{field: value})
      {:ok, %ParticipantAnswer{}}

      iex> create_participant_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant_answer(attrs \\ %{}) do
    %ParticipantAnswer{}
    |> ParticipantAnswer.changeset(attrs)
    |> Repo.insert()
  end

  def create_participant_answer(attrs \\ %{}, participant_id, question_id) do
    participant = Participants.get_participant!(participant_id)
    question = Questions.get_question!(question_id)
    attrs = Map.put(attrs, "result", :assessing)

    %ParticipantAnswer{}
    |> ParticipantAnswer.changeset(attrs, participant, question)
    |> Repo.insert()
  end

  @doc """
  Updates a participant_answer.

  ## Examples

      iex> update_participant_answer(participant_answer, %{field: new_value})
      {:ok, %ParticipantAnswer{}}

      iex> update_participant_answer(participant_answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant_answer(%ParticipantAnswer{} = participant_answer, attrs) do
    participant_answer
    |> ParticipantAnswer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a participant_answer.

  ## Examples

      iex> delete_participant_answer(participant_answer)
      {:ok, %ParticipantAnswer{}}

      iex> delete_participant_answer(participant_answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant_answer(%ParticipantAnswer{} = participant_answer) do
    Repo.delete(participant_answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant_answer changes.

  ## Examples

      iex> change_participant_answer(participant_answer)
      %Ecto.Changeset{data: %ParticipantAnswer{}}

  """
  def change_participant_answer(%ParticipantAnswer{} = participant_answer, attrs \\ %{}) do
    ParticipantAnswer.changeset(participant_answer, attrs)
  end
end
