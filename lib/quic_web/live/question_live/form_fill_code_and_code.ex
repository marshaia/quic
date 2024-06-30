defmodule QuicWeb.QuestionLive.FormFillCodeAndCode do
  use QuicWeb, :live_component

  alias Quic.Parameters
  # alias Quic.Parameters.Parameter

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- language --%>
      <.simple_form
        class="w-full -mt-2"
        :let={f}
        for={@changeset}
        id={"#{@id}-language-form"}
        phx-change="changedLanguage"
        phx-submit="ignore"
        phx-target={@myself}
      >
        <.input
          field={f[:language]}
          type="select"
          label="Programming Language"
          prompt="Choose a language"
          options={["C": :c, "Python": :python]}
        />
      </.simple_form>

      <hr class="w-full mt-10 mb-5"/>

      <%!-- CODE/TEMPLATE --%>
      <p class="text-left font-bold text-[var(--primary-color-text)] mt-8 mb-2"><%= if @type === :code, do: "Participant Template", else: "Question Code" %></p>
      <.code_editor editor_id={"#{@id}-code"} loading={@loading} text={if Map.has_key?(@changeset.changes, :code), do: @changeset.changes.code, else: (if Map.has_key?(@changeset.data, :code), do: @changeset.data.code, else: "")} />

      <%!-- CORRECT ANSWERS --%>
      <%= if @type === :fill_the_code do %>
        <% answer = (if Map.has_key?(@changeset.changes, :correct_answers), do: @changeset.changes.correct_answers, else: (if Map.has_key?(@changeset.data, :correct_answers), do: @changeset.data.correct_answers, else: %{})) %>
        <p class="text-left font-bold text-[var(--primary-color-text)] mt-8 mb-2">Answers Code</p>
        <.code_editor editor_id={"#{@id}-answers"} loading={@loading} text={Parameters.parse_correct_answers_to_string(answer)} />
      <% end %>

      <hr class="w-full mt-10 mb-5"/>

      <%!-- TEST FILE --%>
      <p class="text-left font-bold text-[var(--primary-color-text)] mt-8 mb-2">Test File</p>
      <.code_editor editor_id={"#{@id}-test-file"} loading={@loading} text={if Map.has_key?(@changeset.changes, :test_file), do: @changeset.changes.test_file, else: (if Map.has_key?(@changeset.data, :test_file), do: @changeset.data.test_file, else: "")} />

      <%!-- TESTS --%>
      <% tests = (if Map.has_key?(@changeset.changes, :tests), do: @changeset.changes.tests, else: (if Map.has_key?(@changeset.data, :tests), do: @changeset.data.tests, else: [])) %>
      <p class="mt-8 mb-1 font-bold text-left">Tests</p>
      <.code_editor editor_id={"#{@id}-tests"} loading={@loading} text={Parameters.parse_tests_to_string(tests)} />
    </div>
    """
  end

  @impl true
  def update(%{loading: loading, parameters: parameters, type: type, id_editor: id} = assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket
        |> assign(:loading, loading)
        |> assign(:changeset, parameters)
        |> assign(:type, type)
        |> assign(:id, id)}
  end

  @impl true
  def handle_event("changedLanguage", %{"parameter" => %{"language" => language}}, socket) do
    send(self(), {:changed_language, %{"language" => language}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end
end
