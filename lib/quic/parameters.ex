defmodule Quic.Parameters do
  @moduledoc """
  The Parameters context.
  """

  import Ecto.Query, warn: false
  alias Quic.Repo

  alias Quic.Parameters.Parameter

  @doc """
  Returns the list of parameters.

  ## Examples

      iex> list_parameters()
      [%Parameter{}, ...]

  """
  def list_parameters do
    Repo.all(Parameter)
  end

  @doc """
  Gets a single parameter.

  Raises `Ecto.NoResultsError` if the Parameter does not exist.

  ## Examples

      iex> get_parameter!(123)
      %Parameter{}

      iex> get_parameter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_parameter!(id), do: Repo.get!(Parameter, id)

  @doc """
  Creates a parameter.

  ## Examples

      iex> create_parameter(%{field: value})
      {:ok, %Parameter{}}

      iex> create_parameter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_parameter(attrs \\ %{}) do
    %Parameter{}
    |> Parameter.changeset(attrs)
    |> Repo.insert()
  end

  def create_parameter_with_question(attrs \\ %{}, question) do
    %Parameter{}
    |> Parameter.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:question, question)
    |> Repo.insert()
  end

  @doc """
  Updates a parameter.

  ## Examples

      iex> update_parameter(parameter, %{field: new_value})
      {:ok, %Parameter{}}

      iex> update_parameter(parameter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_parameter(%Parameter{} = parameter, attrs) do
    parameter
    |> Parameter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a parameter.

  ## Examples

      iex> delete_parameter(parameter)
      {:ok, %Parameter{}}

      iex> delete_parameter(parameter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_parameter(%Parameter{} = parameter) do
    Repo.delete(parameter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking parameter changes.

  ## Examples

      iex> change_parameter(parameter)
      %Ecto.Changeset{data: %Parameter{}}

  """
  def change_parameter(%Parameter{} = parameter, attrs \\ %{}) do
    Parameter.changeset(parameter, attrs)
  end

  def get_parameters_map(new_param, changeset) do
    if Map.has_key?(new_param, "code") do
      %{
        "language" => (if Map.has_key?(changeset.changes, :language), do: changeset.changes.language, else: (if Map.has_key?(changeset.data, :language), do: changeset.data.language, else: :c)),
        "correct_answers" => (if Map.has_key?(changeset.changes, :correct_answers), do: changeset.changes.correct_answers, else: (if Map.has_key?(changeset.data, :correct_answers), do: changeset.data.correct_answers, else: %{})),
        "tests" => (if Map.has_key?(changeset.changes, :tests), do: changeset.changes.tests, else: (if Map.has_key?(changeset.data, :tests), do: changeset.data.tests, else: [])),
        "test_file" => (if Map.has_key?(changeset.changes, :test_file), do: changeset.changes.test_file, else: (if Map.has_key?(changeset.data, :test_file), do: changeset.data.test_file, else: ""))
      }
    else if Map.has_key?(new_param, "correct_answers") do
      %{
        "language" => (if Map.has_key?(changeset.changes, :language), do: changeset.changes.language, else: (if Map.has_key?(changeset.data, :language), do: changeset.data.language, else: :c)),
        "code" => (if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if Map.has_key?(changeset.data, :code), do: changeset.data.code, else: "")),
        "tests" => (if Map.has_key?(changeset.changes, :tests), do: changeset.changes.tests, else: (if Map.has_key?(changeset.data, :tests), do: changeset.data.tests, else: [])),
        "test_file" => (if Map.has_key?(changeset.changes, :test_file), do: changeset.changes.test_file, else: (if Map.has_key?(changeset.data, :test_file), do: changeset.data.test_file, else: ""))
      }
      else if Map.has_key?(new_param, "tests") do
        %{
          "language" => (if Map.has_key?(changeset.changes, :language), do: changeset.changes.language, else: (if Map.has_key?(changeset.data, :language), do: changeset.data.language, else: :c)),
          "correct_answers" => (if Map.has_key?(changeset.changes, :correct_answers), do: changeset.changes.correct_answers, else: (if Map.has_key?(changeset.data, :correct_answers), do: changeset.data.correct_answers, else: %{})),
          "code" => (if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if Map.has_key?(changeset.data, :code), do: changeset.data.code, else: "")),
          "test_file" => (if Map.has_key?(changeset.changes, :test_file), do: changeset.changes.test_file, else: (if Map.has_key?(changeset.data, :test_file), do: changeset.data.test_file, else: ""))
        }
      else if Map.has_key?(new_param, "language") do
        %{
          "tests" => (if Map.has_key?(changeset.changes, :tests), do: changeset.changes.tests, else: (if Map.has_key?(changeset.data, :tests), do: changeset.data.tests, else: [])),
          "correct_answers" => (if Map.has_key?(changeset.changes, :correct_answers), do: changeset.changes.correct_answers, else: (if Map.has_key?(changeset.data, :correct_answers), do: changeset.data.correct_answers, else: %{})),
          "code" => (if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if Map.has_key?(changeset.data, :code), do: changeset.data.code, else: "")),
          "test_file" => (if Map.has_key?(changeset.changes, :test_file), do: changeset.changes.test_file, else: (if Map.has_key?(changeset.data, :test_file), do: changeset.data.test_file, else: ""))
        }
      else if Map.has_key?(new_param, "test_file") do
        %{
          "language" => (if Map.has_key?(changeset.changes, :language), do: changeset.changes.language, else: (if Map.has_key?(changeset.data, :language), do: changeset.data.language, else: :c)),
          "correct_answers" => (if Map.has_key?(changeset.changes, :correct_answers), do: changeset.changes.correct_answers, else: (if Map.has_key?(changeset.data, :correct_answers), do: changeset.data.correct_answers, else: %{})),
          "code" => (if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if Map.has_key?(changeset.data, :code), do: changeset.data.code, else: "")),
          "tests" => (if Map.has_key?(changeset.changes, :tests), do: changeset.changes.tests, else: (if Map.has_key?(changeset.data, :tests), do: changeset.data.tests, else: []))
        }
      end
      end
      end
      end
    end
  end

  def create_parameters_changeset(type, %{new_question: new_question} = params) do
    if new_question do
      test_file = "#include <stdio.h>\n\nint sum(int a, int b);\n\nint main() {\n  \n}"
      tests = [%{"input" => "1,2", "output" => "3"}]

      case type do
        :fill_the_code -> change_parameter(%Parameter{}, %{
          "code" => "int sum({{res1}}, int b) {\n  return a+b;\n}",
          "language" => :c,
          "correct_answers" => %{"res1" => "int a"},
          "test_file" => test_file,
          "tests" => tests
        })
        :code -> change_parameter(%Parameter{}, %{
          "code" => "int sum(int a, int b) {\n\n}",
          "language" => :c,
          "correct_answers" => %{},
          "test_file" => test_file,
          "tests" => tests
        })
        _ -> nil
      end
    else
      case type do
        t when t in [:fill_the_code, :code] ->
          %{question: question} = params
          change_parameter(question.parameters)
        _ -> nil
      end
    end
  end

  def evaluate_params(params) do
    if Map.has_key?(params, "correct_answers") do
      %{"correct_answers" => string} = params
      %{"correct_answers" => parse_correct_answers_to_map(string)}
    else
      if Map.has_key?(params, "tests") do
        %{"tests" => tests} = params
        %{"tests" => parse_tests_to_array(tests)}
      else
        params
      end
    end
  end

  def parse_correct_answers_to_string(correct_answers) when is_map(correct_answers) do
    Enum.reduce(correct_answers, "", fn {key, value}, acc -> acc <> "#{key}:#{value}\n"end)
  end

  def parse_correct_answers_to_map(correct_answers) when is_binary(correct_answers) do
    lines = String.split(correct_answers, "\n", trim: true)
    Enum.reduce(lines, %{}, fn line, acc ->
      if String.match?(line, ~r/\w+:(.+)/) do
        [key, value] = String.split(line, ":", trim: true)
        Map.put(acc, key, value)
      else
        acc
      end
    end)
  end

  def parse_tests_to_string(tests) when is_list(tests) do
    Enum.reduce(tests, "", fn test, acc ->
      input = (if Map.has_key?(test, "input"), do: test["input"], else: "")
      output = (if Map.has_key?(test, "output"), do: test["output"], else: "")
      acc <> input <> ":" <> output <> "\n"
    end)
  end

  def parse_tests_to_array(tests) when is_binary(tests) do
    lines = String.split(tests, "\n", trim: true)
    Enum.reduce(lines, [], fn line, acc ->
      if String.match?(line, ~r/^:\w+[\w,]*/) do
        [output] = String.split(line, ":", trim: true)
        Enum.concat(acc, [%{"output" => output}])

      else
        if String.match?(line, ~r/^\w+[\w,]*:$/) do
          [input] = String.split(line, ":", trim: true)
          Enum.concat(acc, [%{"input" => input}])
        else
          if String.match?(line, ~r/\w+[\w,]*:\w+[\w,]*/) do
            [input, output] = String.split(line, ":", trim: true)
            Enum.concat(acc, [%{"input" => input, "output" => output}])
          else
            acc
          end
        end
      end
    end)
  end


  def put_correct_answers_in_code_changeset(changeset) do
    code = (if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if changeset.data.code !== nil, do: changeset.data.code, else: ""))
    answers = (if Map.has_key?(changeset.changes, :correct_answers), do: changeset.changes.correct_answers, else: (if changeset.data.correct_answers !== nil, do: changeset.data.correct_answers, else: %{}))

    Enum.reduce(answers, code, fn {key, value}, acc ->
      String.replace(acc, ~r/{{#{key}}}/, "#{value}")
    end)
  end

  def put_correct_answers_in_code(parameter) do
    Enum.reduce(parameter.correct_answers, parameter.code, fn {key, value}, acc ->
      String.replace(acc, ~r/{{#{key}}}/, "#{value}")
    end)
  end

  def put_correct_answers_participant_in_code(code, answers) do
    Enum.reduce(answers, code, fn {key, value}, acc ->
      String.replace(acc, ~r/{{#{key}}}/, "#{value}")
    end)
  end
end
