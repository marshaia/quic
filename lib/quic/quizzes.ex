defmodule Quic.Quizzes do
  @moduledoc """
  The Quizzes context.
  """

  import Ecto.Query, warn: false
  alias Quic.Accounts.Author
  alias Quic.Repo

  alias Quic.Quizzes.Quiz

  require Logger

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
    author = Repo.get(Author, id) |> Repo.preload([quizzes: from(q in Quiz, order_by: [desc: q.inserted_at])])
    author.quizzes
  end

  def list_all_author_available_quizzes(id) do
    # add quizzes owned by author, shared within teams or with privacy set to :public
    query = from q in Quiz,
      join: a in Author, on: a.id == q.author_id,
      where: q.author_id == ^id,
      select: %{id: q.id, name: q.name, description: q.description, total_points: q.total_points, author_name: a.display_name}

    Repo.all(query)
  end

  def list_all_author_quizzes_filtered(id, filter) do
    search_pattern = "%#{filter}%"
    query = from q in Quiz,
      join: a in Author, on: a.id == q.author_id,
      where: q.author_id == ^id and (
        ilike(q.name, ^search_pattern) or
        ilike(q.description, ^search_pattern) or
        ilike(a.display_name, ^search_pattern)
      ),
      select: %{id: q.id, name: q.name, description: q.description, total_points: q.total_points, author_name: a.display_name}

    Repo.all(query)
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
  def get_quiz!(id), do: Repo.get!(Quiz, id) |> Repo.preload(:author) |> Repo.preload(:questions) |> Repo.preload(questions: :answers)

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


  def update_quiz_points(quiz_id) do
    quiz = get_quiz!(quiz_id)
    newTotal = Enum.reduce(quiz.questions, 0, fn question, acc -> question.points + acc end)

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

  def is_allowed_to_access?(quiz_id, author) do
    author_quizzes = list_all_author_quizzes(author.id)
    cond1 = Enum.any?(author_quizzes, fn quiz -> quiz.id === quiz_id end)

    cond1
  end
end
