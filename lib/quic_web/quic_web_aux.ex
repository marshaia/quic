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
      :true_false -> "bg-[var(--blue)]"
      :open_answer -> "bg-[var(--dark-green)]"
      :fill_the_blanks -> "bg-[var(--fifth-color)]"
      :fill_the_code -> "bg-[var(--third-color)]"
      :code -> "bg-[var(--fourth-color)]"
    end
  end

  # def readable_name(type) when is_binary(type) do
  #   case type do
  #     "single_choice" -> "Single Choice"
  #     "multiple_choice" -> "Multiple Choice"
  #     "true_false" -> "True or False"
  #     "open_answer" -> "Open Answer"
  #     "fill_the_blanks" -> "Fill in the Blanks"
  #     "fill_the_code" -> "Fill the Code"
  #     "code" -> "Code"
  #   end
  # end
  # def get_type_color(type) when is_binary(type) do
  #   case type do
  #     "single_choice" -> "bg-[var(--turquoise)]"
  #     "multiple_choice" -> "bg-[var(--second-color)]"
  #     "true_false" -> "bg-[var(--blue)]"
  #     "open_answer" -> "bg-[var(--dark-green)]"
  #     "fill_the_blanks" -> "bg-[var(--fifth-color)]"
  #     "fill_the_code" -> "bg-[var(--third-color)]"
  #     "code" -> "bg-[var(--fourth-color)]"
  #   end
  # end

end
