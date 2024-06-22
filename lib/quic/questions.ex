defmodule Quic.Questions do
  @moduledoc """
  The Questions context.
  """

  import Ecto.Query, warn: false

  alias Quic.Parameters
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
  def get_question!(id), do: Repo.get!(Question, id) |> Repo.preload(:quiz) |> Repo.preload(:parameters) |> Repo.preload([answers: from(a in QuestionAnswer, order_by: a.inserted_at)])

  def get_question_answers!(id) do
    question = Repo.get!(Question, id) |> Repo.preload([answers: from(a in QuestionAnswer, order_by: a.inserted_at)])
    question.answers
  end

  def get_question_with_position(quiz_id, position) do
    query = from q in Question, where: q.quiz_id == ^quiz_id and q.position == ^position
    res = Repo.all(query)
    Enum.at(res, 0, nil)
  end
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

  def create_question(attrs \\ %{}, quiz_id, answers_changesets, parameters) do
    quiz = Quizzes.get_quiz!(quiz_id)

    result = %Question{}
      |> Question.changeset(attrs, quiz)
      |> Repo.insert()

    case result do
      {:ok, question} ->
        Enum.each(answers_changesets,
          fn answer_changeset ->
            changes = answer_changeset.changes
            params = %{"answer" => changes.answer, "is_correct" => (if Map.has_key?(changes, :is_correct), do: changes.is_correct, else: false)}
            {:ok, _} = create_answer_with_question(params, question.id)
          end)

        if question.type === :fill_the_code || question.type === :code do
          param_map = %{"code" => parameters.changes.code, "language" => parameters.changes.language, "tests" => parameters.changes.tests}
          param_map = (if question.type === :fill_the_code, do: Map.put(param_map, "correct_answers", parameters.changes.correct_answers), else: Map.put(param_map, "correct_answers", %{}))
          {:ok, _} = Parameters.create_parameter_with_question(param_map, question)
        end


        {:ok, question}

      {:error, _} -> result
    end
  end

  def duplicate_question(attrs \\ %{}, quiz_id, question) do
    quiz = Quizzes.get_quiz!(quiz_id)

    result = %Question{}
      |> Question.changeset(attrs, quiz)
      |> Repo.insert()

    case result do
      {:ok, new_question} ->
        Enum.each(question.answers,
          fn answer ->
            params = %{"answer" => answer.answer, "is_correct" => answer.is_correct}
            {:ok, _} = create_answer_with_question(params, new_question.id)
          end)

        if question.type === :fill_the_code || question.type === :code do
          parameters = question.parameters
          param_map = %{"code" => parameters.code, "language" => parameters.language, "tests" => parameters.tests}
          param_map = (if question.type === :fill_the_code, do: Map.put(param_map, "correct_answers", parameters.correct_answers), else: Map.put(param_map, "correct_answers", %{}))
          {:ok, _} = Parameters.create_parameter_with_question(param_map, new_question)
        end

        {:ok, question}

      {:error, _} -> result
    end
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

  def update_question(question, attrs \\ %{}, answers_attrs \\ [], parameters_changeset) do
    result = question
      |> Question.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, question} ->
        Enum.reduce(answers_attrs, 0,
          fn answer_changeset, acc ->
            answer_bd = Enum.at(question.answers, acc, %QuestionAnswer{})
            params = %{
              "answer" => (if Map.has_key?(answer_changeset.changes, :answer), do: answer_changeset.changes.answer, else: answer_bd.answer),
              "is_correct" => (if Map.has_key?(answer_changeset.changes, :is_correct), do: answer_changeset.changes.is_correct, else: answer_bd.is_correct)
            }
            {:ok, _} = update_question_answer(answer_bd, params)
            acc + 1
          end
        )

        if question.type === :fill_the_code || question.type === :code do
          parameters = question.parameters
          param_map = %{
            "code" =>  (if Map.has_key?(parameters_changeset.changes, :code), do: parameters_changeset.changes.code, else: parameters.code),
            "language" => (if Map.has_key?(parameters_changeset.changes, :language), do: parameters_changeset.changes.language, else: parameters.language),
            "tests" => (if Map.has_key?(parameters_changeset.changes, :tests), do: parameters_changeset.changes.tests, else: parameters.tests),
            "correct_answers" => (if Map.has_key?(parameters_changeset.changes, :correct_answers), do: parameters_changeset.changes.correct_answers, else: parameters.correct_answers)
          }
          #param_map = (if question.type === :fill_the_code, do: Map.put(param_map, "correct_answers", (if Map.has_key?(parameters_changeset.changes, :correct_answers), do: parameters_changeset.changes.correct_answers, else: parameters.correct_answers)))
          {:ok, _} = Parameters.update_parameter(parameters, param_map)
        end

        {:ok, question}

      {:error, _} -> result
    end
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

  def create_question_placeholders(type, changeset) do
    case type do
      :fill_the_code ->
        changeset |> Map.put(:description, "Choose the programming language you want to evaluate, then, when you want to insert a segment of code to complete, simply add __`{{<id>}}`__ in the intended place (the __`<id>`__ can only have 'word' characters).\n\n Then, to insert the correct answers, use the syntax like it's exemplified: __`<id>:<correct_answer>`__.\n\nFinally, in order to test the submitted code, please insert tests with the syntax __`<input>:<output>`__ like exemplified.")
      :code ->
        changeset |> Map.put(:description, "Choose the programming language you want to evaluate, then, add the complete code you want your Participants to submit on Answer editor.\n\nIn order to test the submitted code, please insert tests with the syntax __`<input>:<output>`__ like exemplified.")
      :fill_the_blanks ->
        changeset |> Map.put(:description, "When you want to insert the piece of text for the Participants to complete, you can choose how to display it on the question. The system will evaluate only the answer, not the question's description.\nFor example:\n\n`We only consider the _____ answers!`")
      _ -> changeset
    end
  end
end
