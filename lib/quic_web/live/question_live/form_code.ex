defmodule QuicWeb.QuestionLive.FormCode do
  use QuicWeb, :live_component

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full mt-2">
      <div
        class="hidden"
        id={@id}
        phx-hook="AceEditor"
        phx-update="ignore"><%= show_code(@is_answer, @changeset) %></div>

      <%!-- <.simple_form hidden :let={f} for={@changeset}>
        <.input hidden type="hidden" field={f[:answer]} id={@id <> "-code"} phx-update="ignore"></.input>
      </.simple_form> --%>
    </div>
    """
  end

  @impl true
  def update(%{answers: answers, id_editor: id, is_answer: is_answer} = assigns, socket) do
    {:ok, socket
        |> assign(assigns)
        |> assign(:is_answer, is_answer)
        |> assign(:changeset, (if is_answer, do: Enum.at(answers, 0, Questions.change_question_answer(%QuestionAnswer{})), else: answers))
        |> assign(:id, id)}
  end

  defp show_code(is_answer, changeset) do
    if is_answer do
      if Map.has_key?(changeset.changes, :answer), do: changeset.changes.answer, else: (if Map.has_key?(changeset.data, :answer), do: changeset.data.answer, else: "")
    else
      if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if Map.has_key?(changeset.data, :code), do: changeset.data.code, else: "")
    end
  end
end
