defmodule QuicWeb.QuicWebAux do

  def readable_name(type) when is_atom(type) do
    case type do
      :single_choice -> "Single Choice"
      :multiple_choice -> "Multiple Choice"
      :true_false -> "True or False"
      :open_answer -> "Open Answer"
      :fill_the_blanks -> "Fill the Blank"
      :fill_the_code -> "Fill the Code"
      :code -> "Code"
    end
  end

  def get_type_color(type) when is_atom(type) do
    case type do
      :single_choice -> "bg-[var(--blue)]"
      :multiple_choice -> "bg-[var(--second-color)]"
      :true_false -> "bg-gray-400"
      :open_answer -> "dark:bg-[var(--dark-green-2)] bg-[var(--dark-green)]"
      :fill_the_blanks -> "bg-[var(--fifth-color)] dark:bg-[#d69825]"
      :fill_the_code -> "bg-[var(--third-color)]"
      :code -> "bg-[var(--fourth-color)]"
    end
  end

  def question_num_of_answers(type) do
    case type do
      :single_choice -> 4
      :multiple_choice -> 4
      :true_false -> 1
      :open_answer -> 0
      :fill_the_blanks -> 1
      :fill_the_code -> 1
      :code -> 1
    end
  end

  def session_type_translate(type) do
    case type do
      :monitor_paced -> "Monitor Paced"
      :participant_paced -> "Participant Paced"
      _ -> ""
    end
  end

  def user_color(number) do
    case rem(number, 5) do
      1 -> "text-[var(--second-color)]"
      2 -> "text-[var(--green)]"
      3 -> "text-[var(--fourth-color)]"
      4 -> "text-[var(--blue)]"
      _ -> "text-[var(--fifth-color)]"
    end
  end

  def session_status_color(status) do
    case status do
      :open -> "bg-[var(--green)]"
      :on_going -> "bg-yellow-500"
      :closed -> "bg-red-700"
    end
  end

  def session_status_translate(status) do
    case status do
      :open -> "OPEN"
      :on_going -> "ON GOING"
      :closed -> "CLOSED"
    end
  end

  def progress_percentage(participant_question, quiz_total_questions) when quiz_total_questions > 0 do
    Float.round((participant_question / quiz_total_questions) * 100, 0)
  end

  # Earmark AST Parser
  @doc"""
    Transforms every {{id}} found in the AST (in every `code` node) into __id__.
  """
  def parse_text(text) do
    case Earmark.Parser.as_ast(text, code_class_prefix: "lang- language-") do
      {:error, _, _} -> text
      {:ok, ast, _} -> parse_AST(ast)
    end
  end

  def parse_AST(ast) do
    transformer =
      fn
        {"code", attrs, content, meta} ->
          new_content = Enum.map(content, fn code -> String.replace(code, ~r/{{(\w+)}}/, "__\\1__") end)
          {:replace, {"code", attrs, new_content, meta}}
        other -> other
      end

    Earmark.Transform.map_ast(ast, transformer)
  end

end
