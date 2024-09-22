defmodule Quic.Questions do
  @moduledoc """
  The Questions context.
  """

  import Ecto.Query, warn: false

  alias Quic.{Repo, Quizzes, Parameters, Participants, ParticipantAnswers, CodeGrader}
  alias Quic.Questions.{Question, QuestionAnswer}

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
    try do
      # Start a transaction to ensure atomicity
      Repo.transaction(fn ->
        quiz = Quizzes.get_quiz!(quiz_id)
        {:ok, question} = %Question{} |> Question.changeset(attrs, quiz) |> Repo.insert()

        Enum.each(answers_changesets,
          fn answer_changeset ->
            changes = answer_changeset.changes
            params = %{"answer" => changes.answer, "is_correct" => (if Map.has_key?(changes, :is_correct), do: changes.is_correct, else: false)}
            create_answer_with_question(params, question.id)
          end)

        if question.type === :fill_the_code || question.type === :code do
          param_map = %{"code" => parameters.changes.code, "language" => parameters.changes.language, "tests" => parameters.changes.tests, "test_file" => parameters.changes.test_file}
          param_map = (if question.type === :fill_the_code, do: Map.put(param_map, "correct_answers", parameters.changes.correct_answers), else: Map.put(param_map, "correct_answers", %{}))
          Parameters.create_parameter_with_question(param_map, question)
        end

        {:ok, question}
      end)

    rescue
      _ -> {:error, "Error running transaction"}
    end
  end

  def create_question_from_existing_one(attrs \\ %{}, quiz_id, answers_params, parameters_params) do
    try do
      # Start a transaction to ensure atomicity
      Repo.transaction(
        fn ->
          quiz = Quizzes.get_quiz!(quiz_id)
          {:ok, question} = %Question{} |> Question.changeset(attrs, quiz) |> Repo.insert()

          Enum.each(answers_params, fn params -> create_answer_with_question(params, question.id) end)
          if question.type === :fill_the_code || question.type === :code, do: Parameters.create_parameter_with_question(parameters_params, question)
        end)

    rescue
      _ -> {:error, "Error creating question"}
    end
  end

  def duplicate_question(attrs \\ %{}, quiz_id, question) do
    try do
      # Start a transaction to ensure atomicity
      Repo.transaction(fn ->
        quiz = Quizzes.get_quiz!(quiz_id)
        {:ok, new_question} = %Question{} |> Question.changeset(attrs, quiz) |> Repo.insert()

        Enum.each(question.answers,
          fn answer ->
            params = %{"answer" => answer.answer, "is_correct" => answer.is_correct}
            {:ok, _} = create_answer_with_question(params, new_question.id)
          end)

        if question.type === :fill_the_code || question.type === :code do
          parameters = question.parameters
          param_map = %{"code" => parameters.code, "language" => parameters.language, "tests" => parameters.tests, "test_file" => parameters.test_file}
          param_map = (if question.type === :fill_the_code, do: Map.put(param_map, "correct_answers", parameters.correct_answers), else: Map.put(param_map, "correct_answers", %{}))
          {:ok, _} = Parameters.create_parameter_with_question(param_map, new_question)
        end
      end)

    rescue
      _ -> {:error, "Error running transaction"}
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
    try do
      # Start a transaction to ensure atomicity
      Repo.transaction(fn ->
        {:ok, question} = question |> Question.changeset(attrs) |> Repo.update()

        Enum.reduce(answers_attrs, 0,
          fn answer_changeset, acc ->
            answer_bd = Enum.at(question.answers, acc, %QuestionAnswer{})
            params = %{
              "answer" => (if Map.has_key?(answer_changeset.changes, :answer), do: answer_changeset.changes.answer, else: answer_bd.answer),
              "is_correct" => (if Map.has_key?(answer_changeset.changes, :is_correct), do: answer_changeset.changes.is_correct, else: answer_bd.is_correct)
            }
            update_question_answer(answer_bd, params)
            acc + 1
          end
        )

        if question.type === :fill_the_code || question.type === :code do
          parameters = question.parameters
          param_map = %{
            "code" =>  (if Map.has_key?(parameters_changeset.changes, :code), do: parameters_changeset.changes.code, else: parameters.code),
            "language" => (if Map.has_key?(parameters_changeset.changes, :language), do: parameters_changeset.changes.language, else: parameters.language),
            "test_file" => (if Map.has_key?(parameters_changeset.changes, :test_file), do: parameters_changeset.changes.test_file, else: parameters.test_file),
            "tests" => (if Map.has_key?(parameters_changeset.changes, :tests), do: parameters_changeset.changes.tests, else: parameters.tests),
            "correct_answers" => (if Map.has_key?(parameters_changeset.changes, :correct_answers), do: parameters_changeset.changes.correct_answers, else: parameters.correct_answers)
          }
          Parameters.update_parameter(parameters, param_map)
        end
      end)

    rescue
      _ -> {:error, "Error running transaction"}
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

  def question_belongs_to_quiz?(question_id, quiz_id) do
    try do
      question = get_question!(question_id)
      question.quiz.id === quiz_id
    rescue
      _ -> false
    end

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
        changeset |> Map.put(:description, "To insert a segment of code to complete, simply add __`{{id}}`__ in the intended place (the __`id`__ can only have ASCII characters). To associate the correct answers, use the syntax: __`id:correct_answer`__.\n\nFinally, to test the submitted code, please complete the Test File and insert input/output tests with the syntax __`input:output`__ (strings don't need the double quotes).")
      :code ->
        changeset |> Map.put(:description, "Choose the programming language you want to evaluate, then, add the complete code you want your Participants to submit on the code editor.\n\nIn order to test the submitted code, please complete the Test File and insert input/output tests with the syntax __`input:output`__ (strings don't need the double quotes).")
      :fill_the_blanks ->
        changeset |> Map.put(:description, "When you want to insert the piece of text for the Participants to complete, you can choose how to display it on the question. The system will evaluate only the answer you insert, not the question's description.\nFor example:\n\n`We only consider the _____ answers!`")
      _ -> changeset
    end
  end


  def assess_submission(participant_id, question_id, answer) do
    participant = Participants.get_participant!(participant_id)
    question = Enum.find(participant.session.quiz.questions, fn q -> q.id === question_id end)
    question_answers = Enum.filter(participant.session.quiz.answers, fn a -> a.question_id === question_id end)

    participant_answer = ParticipantAnswers.format_participant_answer(question.type, answer)
    ParticipantAnswers.create_participant_answer(%{"answer" => participant_answer, "result" => :assessing}, participant_id, question_id)

    case question.type do
      :single_choice -> assess_single_choice(question_answers, answer)
      :multiple_choice -> assess_multiple_choice(question_answers, answer)
      :true_false -> assess_true_false(question_answers, answer)
      :fill_the_blanks -> assess_fill_the_blanks(question_answers, answer)
      :open_answer -> %{result: :incorrect}
      :fill_the_code ->
        parameters = Enum.find(participant.session.quiz.parameters, fn p -> p.question_id === question_id end)
        complete_answer = Parameters.put_correct_answers_participant_in_code(parameters.code, answer)
        assess_code(parameters, participant_id, complete_answer)
      :code ->
        parameters = Enum.find(participant.session.quiz.parameters, fn p -> p.question_id === question_id end)
        assess_code(parameters, participant_id, answer)
      _ -> %{result: :error, error_reason: "Question type not supported"}
    end
  end

  def assess_single_choice(question_answers, answer) do
    selected_answer = Enum.find(question_answers, fn a -> a.id === answer end)
    if selected_answer !== nil && selected_answer.is_correct, do: %{result: :correct}, else: %{result: :incorrect}
  end

  def assess_multiple_choice(question_answers, selected_answers) do
    # question correct answers
    correct_answers = Enum.reduce(question_answers, [], fn a, acc -> if a.is_correct, do: [a.id | acc], else: acc end)
    how_many_true = Enum.count(correct_answers)

    # check participant didn't select incorrect answers
    selected_only_correct_answers = Enum.reduce(selected_answers, true, fn answer_id, acc -> if !Enum.member?(correct_answers, answer_id), do: false, else: acc end)

    # check if participant selected only correct answers and all correct answers possible
    if selected_only_correct_answers && how_many_true === Enum.count(selected_answers), do: %{result: :correct}, else: %{result: :incorrect}
  end

  def assess_true_false(question_answers, participant_answer) do
    participant_answer = (if participant_answer === "true", do: true, else: false)
    question_answer = Enum.at(question_answers, 0, nil)
    case question_answer do
      nil -> %{result: :incorrect}
      answer -> if answer.is_correct === participant_answer, do: %{result: :correct}, else: %{result: :incorrect}
    end
  end

  def assess_fill_the_blanks(question_answers, participant_answer) do
    question_answer = Enum.at(question_answers, 0, nil)
    case question_answer do
      nil -> %{result: :incorrect}
      answer -> if String.match?(participant_answer, ~r/^ *#{answer.answer} *$/i), do: %{result: :correct}, else: %{result: :incorrect}
    end
  end


  def assess_code(parameters, participant_id, participant_answer) do
    case CodeGrader.grade_code(participant_id, participant_answer, parameters) do
      {:ok, _res} -> %{result: :correct}
      {:failed, msg} -> %{result: :incorrect, error_reason: msg}
      {:error, msg} -> %{result: :error, error_reason: msg}
    end
  end
end
