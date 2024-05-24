defmodule QuicWeb.QuicWebAux do

  def readable_name(type) when is_atom(type) do
    case type do
      :single_choice -> "Single Choice"
      :multiple_choice -> "Multiple Choice"
      :true_false -> "True or False"
      :open_answer -> "Open Answer"
      :fill_the_blanks -> "Fill in the Blanks"
      :fill_the_code -> "Fill the Code"
      :code -> "Code"
    end
  end

  def get_type_color(type) when is_atom(type) do
    case type do
      :single_choice -> "bg-[var(--turquoise)]"
      :multiple_choice -> "bg-[var(--second-color)]"
      :true_false -> "bg-gray-500"
      :open_answer -> "bg-[var(--dark-green)]"
      :fill_the_blanks -> "bg-[var(--fifth-color)]"
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
    case rem(number, 6) do
      1 -> "text-[var(--second-color)]"
      2 -> "text-[var(--third-color)]"
      3 -> "text-[var(--fourth-color)]"
      4 -> "text-[var(--fifth-color)]"
      5 -> "text-[var(--green)]"
      _ -> "text-[var(--blue)]"
    end
  end


  def session_status_color(status) do
    case status do
      :open -> "bg-[var(--green)]"
      :on_going -> "bg-yellow-500"
      :closed -> "bg-red-700"
    end
  end

end
