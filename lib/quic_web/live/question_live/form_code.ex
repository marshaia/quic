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
        phx-update="ignore"><%= if Map.has_key?(@changeset.changes, :answer), do: @changeset.changes.answer, else: (if Map.has_key?(@changeset.data, :answer), do: @changeset.data.answer, else: "")%></div>

      <.simple_form hidden :let={f} for={@changeset}>
        <.input hidden type="hidden" field={f[:answer]} id={@id <> "-code"} phx-update="ignore"></.input>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{answers: answers, id_editor: id} = assigns, socket) do
    {:ok, socket
        |> assign(assigns)
        |> assign(:changeset, Enum.at(answers, 0, Questions.change_question_answer(%QuestionAnswer{})))
        |> assign(:id, id)}
  end
end
