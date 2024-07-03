defmodule Quic.Quizzes do
  @moduledoc """
  The Quizzes context.
  """

  import Ecto.Query, warn: false
  alias Quic.{Repo, Questions, Accounts}
  alias Quic.Quizzes.Quiz
  alias Quic.Accounts.Author
  alias Quic.Questions.{QuestionAnswer, Question}



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
    author = Repo.get(Author, id) |> Repo.preload([quizzes: from(q in Quiz, order_by: [desc: q.inserted_at])]) |> Repo.preload(quizzes: [:questions, :author])
    author.quizzes
  end

  def list_all_public_quizzes() do
    query = from q in Quiz, where: q.public == true
    Repo.all(query) |> Repo.preload(:author) |> Repo.preload(:questions)
  end

  def list_all_author_public_quizzes(id) do
    author = Repo.get(Author, id) |> Repo.preload([quizzes: from(q in Quiz, order_by: [desc: q.inserted_at])]) |> Repo.preload(quizzes: [:questions, :author])
    Enum.filter(author.quizzes, fn q -> q.public === true end)
  end

  def list_all_author_teams_quizzes(id) do
    author = Repo.get(Author, id) |> Repo.preload(teams: :quizzes)
    Enum.reduce(author.teams, [], fn team, acc ->  Enum.concat(team.quizzes, acc) end)
  end

  def filter_author_quizzes(author_id, input) do
    if String.length(input) === 0 do
      list_all_author_quizzes(author_id)
    else
      Enum.reduce(list_all_author_quizzes(author_id), [],
        fn quiz, acc ->
          if (String.match?(quiz.name, ~r/\w*#{input}\w*/i) ||
              String.match?(quiz.description, ~r/\w*#{input}\w*/i) ||
              String.match?(quiz.author.display_name,  ~r/\w*#{input}\w*/i)),
          do: [quiz | acc], else: acc
        end)
    end
  end

  def filter_public_quizzes(input) do
    if String.length(input) === 0 do
      list_all_public_quizzes()
    else
      Enum.reduce(list_all_public_quizzes(), [],
        fn quiz, acc ->
          if (String.match?(quiz.name, ~r/\w*#{input}\w*/i) ||
              String.match?(quiz.description, ~r/\w*#{input}\w*/i) ||
              String.match?(quiz.author.display_name,  ~r/\w*#{input}\w*/i)),
          do: [quiz | acc], else: acc
        end)
    end
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
  def get_quiz!(id), do: Repo.get!(Quiz, id) |> Repo.preload(:author) |> Repo.preload([questions: from(q in Question, order_by: q.position)]) |> Repo.preload(questions: [answers: from(a in QuestionAnswer, order_by: a.inserted_at)]) |> Repo.preload(questions: :parameters)

  def get_quiz_num_questions!(id) do
    quiz = Repo.get!(Quiz, id) |> Repo.preload(:questions)
    Enum.count(quiz.questions)
  end

  def get_quiz_questions!(id) do
    quiz = Repo.get!(Quiz, id) |> Repo.preload([questions: from(q in Question, order_by: [asc: q.position])])
    quiz.questions
  end

  def exists_quiz?(quiz_id) do
    Repo.get(Quiz, quiz_id) !== nil
  rescue
    _ -> false
  end

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

  def duplicate_quiz(attrs \\ %{}, quiz_id, author_id) do
    try do
      Repo.transaction(fn ->
        quiz = get_quiz!(quiz_id)
        author = Accounts.get_author!(author_id)
        {:ok, new_quiz} = %Quiz{} |> Quiz.changeset(attrs, author) |> Repo.insert()

        Enum.each(quiz.questions,
          fn question ->
            question_params = %{"description" => question.description, "position" => question.position, "points" => question.points, "type" => question.type}
            answers = if not Map.has_key?(question, :answers), do: [], else: Enum.reduce(question.answers, [],
              fn answer, acc ->
                params = %{"answer" => answer.answer, "is_correct" => answer.is_correct}
                [params | acc]
              end)
            parameters = if question.type !== :fill_the_code && question.type !== :code, do: nil, else: %{"code" => question.parameters.code, "test_file" => question.parameters.test_file, "language" => question.parameters.language, "correct_answers" => question.parameters.correct_answers, "tests" => question.parameters.tests}

            Questions.create_question_from_existing_one(question_params, new_quiz.id, answers, parameters)
          end)
      end)

    rescue
      _ -> {:error, "Error running transaction"}
    end
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

  def update_quiz_questions_positions(id, position) do
    try do
      Repo.transaction(fn ->
        quiz_questions = get_quiz_questions!(id)
        Enum.each(quiz_questions,
          fn question ->
            if (question.position > position) do
              Questions.update_question(question, %{"position" => question.position - 1})
            end
          end)
      end)
    rescue
      _ -> {:error, "Error running transaction"}
    end
  end

  def send_quiz_question(direction, quiz_id, question_id, quiz_num_questions) do
    try do
      Repo.transaction(fn ->
        question = Questions.get_question!(question_id)
        old_position = question.position
        new_position = question.position + (if direction === :up, do: -1, else: 1)

        if (direction === :up && old_position > 1) || (direction === :down && old_position >= 1 && old_position <= quiz_num_questions) do
          case Questions.get_question_with_position(quiz_id, new_position) do
            nil -> {:error, question}
            switch_question ->
              Questions.update_question(switch_question, %{"position" => old_position})
              Questions.update_question(question, %{"position" => new_position})
              {:ok, question}
          end
        else
          {:error, question}
        end
      end)

    rescue
      _ -> {:error, "Error running transaction"}
    end
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
    belongs_to_author = Enum.any?(author_quizzes, fn quiz -> quiz.id === quiz_id end)

    author_team_quizzes = list_all_author_teams_quizzes(author.id)
    is_in_author_teams = Enum.any?(author_team_quizzes, fn quiz -> quiz.id === quiz_id end)

    quiz_is_public =
      try do
        quiz = get_quiz!(quiz_id)
        quiz.public
      rescue
        _ -> false
      end

    belongs_to_author || is_in_author_teams || quiz_is_public
  end
end
