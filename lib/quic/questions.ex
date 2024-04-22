defmodule Quic.Questions do
  @moduledoc """
  The Questions context.
  """

  import Ecto.Query, warn: false

  alias Quic.Quizzes
  alias Quic.Repo

  alias Quic.Questions.Question
  alias Quic.Questions.QuestionAnswer

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions do
    Repo.all(Question)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id) |> Repo.preload(:quiz) |> Repo.preload(:answers)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  def create_question_with_quiz(attrs \\ %{}, id) do
    quiz = Quizzes.get_quiz!(id)
    %Question{}
    |> Question.changeset(attrs, quiz)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  alias Quic.Questions.QuestionAnswer

  @doc """
  Returns the list of question_answers.

  ## Examples

      iex> list_question_answers()
      [%QuestionAnswer{}, ...]

  """
  def list_question_answers do
    Repo.all(QuestionAnswer)
  end

  @doc """
  Gets a single question_answer.

  Raises `Ecto.NoResultsError` if the Question answer does not exist.

  ## Examples

      iex> get_question_answer!(123)
      %QuestionAnswer{}

      iex> get_question_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question_answer!(id), do: Repo.get!(QuestionAnswer, id) |> Repo.preload(:question)

  @doc """
  Creates a question_answer.

  ## Examples

      iex> create_question_answer(%{field: value})
      {:ok, %QuestionAnswer{}}

      iex> create_question_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question_answer(attrs \\ %{}) do
    %QuestionAnswer{}
    |> QuestionAnswer.changeset(attrs)
    |> Repo.insert()
  end

  def create_answer_with_question(attrs \\ %{}, id) do
    question = get_question!(id)
    %QuestionAnswer{}
    |> QuestionAnswer.changeset(attrs, question)
    |> Repo.insert()
  end

  def answer_belongs_to_question?(question_id, answer_id) do
    answer = get_question_answer!(answer_id)
    answer.question.id === question_id
  end

  @doc """
  Updates a question_answer.

  ## Examples

      iex> update_question_answer(question_answer, %{field: new_value})
      {:ok, %QuestionAnswer{}}

      iex> update_question_answer(question_answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question_answer(%QuestionAnswer{} = question_answer, attrs) do
    question_answer
    |> QuestionAnswer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question_answer.

  ## Examples

      iex> delete_question_answer(question_answer)
      {:ok, %QuestionAnswer{}}

      iex> delete_question_answer(question_answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question_answer(%QuestionAnswer{} = question_answer) do
    Repo.delete(question_answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question_answer changes.

  ## Examples

      iex> change_question_answer(question_answer)
      %Ecto.Changeset{data: %QuestionAnswer{}}

  """
  def change_question_answer(%QuestionAnswer{} = question_answer, attrs \\ %{}) do
    QuestionAnswer.changeset(question_answer, attrs)
  end
end
