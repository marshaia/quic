defmodule Quic.Quizzes do
  @moduledoc """
  The Quizzes context.
  """

  import Ecto.Query, warn: false
  alias Quic.Accounts.Author
  alias Quic.Repo

  alias Quic.Quizzes.Quiz

  @doc """
  Returns the list of quizzes.

  ## Examples

      iex> list_quizzes()
      [%Quiz{}, ...]

  """
  def list_quizzes do
    Repo.all(Quiz)
  end

  def list_all_author_quizzes(id) do
    author = Repo.get(Author, id) |> Repo.preload(:quizzes)
    author.quizzes
  end

  @doc """
  Gets a single quiz.

  Raises `Ecto.NoResultsError` if the Quiz does not exist.

  ## Examples

      iex> get_quiz!(123)
      %Quiz{}

      iex> get_quiz!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quiz!(id), do: Repo.get!(Quiz, id) |> Repo.preload(:author) |> Repo.preload(:questions)

  @doc """
  Creates a quiz.

  ## Examples

      iex> create_quiz(%{field: value})
      {:ok, %Quiz{}}

      iex> create_quiz(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quiz(attrs \\ %{}) do
    %Quiz{}
    |> Quiz.changeset(attrs)
    |> Repo.insert()
  end

  def create_quiz_with_author(attrs \\ %{}, id) do
    author = Repo.get!(Author, id)
    %Quiz{}
    |> Quiz.changeset(attrs, author)
    |> Repo.insert()
  end

  @doc """
  Updates a quiz.

  ## Examples

      iex> update_quiz(quiz, %{field: new_value})
      {:ok, %Quiz{}}

      iex> update_quiz(quiz, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quiz(%Quiz{} = quiz, attrs) do
    quiz
    |> Quiz.changeset(attrs)
    |> Repo.update()
  end


  def update_quiz_points(quiz_id, points) do
    quiz = get_quiz!(quiz_id)
    newTotal = quiz.total_points + points

    quiz
    |> Quiz.changeset(%{total_points: newTotal})
    |> Repo.update()
  end

  def update_quiz_points_when_question_edited(quiz_id, old_points, new_points) do
    quiz = get_quiz!(quiz_id)
    newTotal = quiz.total_points - old_points + new_points

    quiz
    |> Quiz.changeset(%{total_points: newTotal})
    |> Repo.update()
  end


  def update_quiz_points_when_question_deleted(quiz_id, points) do
    quiz = get_quiz!(quiz_id)
    newTotal = quiz.total_points - points

    quiz
    |> Quiz.changeset(%{total_points: newTotal})
    |> Repo.update()
  end

  @doc """
  Deletes a quiz.

  ## Examples

      iex> delete_quiz(quiz)
      {:ok, %Quiz{}}

      iex> delete_quiz(quiz)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quiz(%Quiz{} = quiz) do
    Repo.delete(quiz)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quiz changes.

  ## Examples

      iex> change_quiz(quiz)
      %Ecto.Changeset{data: %Quiz{}}

  """
  def change_quiz(%Quiz{} = quiz, attrs \\ %{}) do
    Quiz.changeset(quiz, attrs)
  end


  def is_owner?(quiz_id, author) do
    quiz = get_quiz!(quiz_id)
    author && quiz && author.id === quiz.author_id
  end
end
