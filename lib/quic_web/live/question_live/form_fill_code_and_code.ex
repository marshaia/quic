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
          options={["C": :c]}
        />
      </.simple_form>

      <%!-- code --%>
      <p class="text-left font-bold text-[var(--primary-color-text)] mt-8 mb-2">Question Code</p>
      <div :if={@loading} id={"#{@id}-code-loading"}>
        <div class="flex items-center justify-center gap-3">
          <Heroicons.arrow_path class="w-5 h-5 text-[var(--primary-color)] animate-spin"/>
          <p>Loading editor</p>
        </div>
      </div>
      <div
        class="hidden"
        id={"#{@id}-code"}
        phx-hook="AceEditor"
        phx-update="ignore"
      ><%= if Map.has_key?(@changeset.changes, :code), do: @changeset.changes.code, else: (if Map.has_key?(@changeset.data, :code), do: @changeset.data.code, else: "") %></div>

      <%!-- answer --%>
      <%= if @type === :fill_the_code do %>
        <% answer = (if Map.has_key?(@changeset.changes, :correct_answers), do: @changeset.changes.correct_answers, else: (if Map.has_key?(@changeset.data, :correct_answers), do: @changeset.data.correct_answers, else: %{})) %>
        <p class="text-left font-bold text-[var(--primary-color-text)] mt-8 mb-2">Answers Code</p>
        <div :if={@loading} id={"#{@id}-answers-loading"}>
          <div class="flex items-center justify-center gap-3">
            <Heroicons.arrow_path class="w-5 h-5 text-[var(--primary-color)] animate-spin"/>
            <p>Loading editor</p>
          </div>
        </div>
        <div
          class="hidden"
          id={"#{@id}-answers"}
          phx-hook="AceEditor"
          phx-update="ignore"
        ><%= Parameters.parse_correct_answers_to_string(answer) %></div>
      <% end %>

      <%!-- tests --%>
      <% tests = (if Map.has_key?(@changeset.changes, :tests), do: @changeset.changes.tests, else: (if Map.has_key?(@changeset.data, :tests), do: @changeset.data.tests, else: [])) %>
      <p class="mt-8 mb-1 font-bold text-left">Tests</p>
      <div :if={@loading} id={"#{@id}-tests-loading"}>
        <div class="flex items-center justify-center gap-3">
          <Heroicons.arrow_path class="w-5 h-5 text-[var(--primary-color)] animate-spin"/>
          <p>Loading editor</p>
        </div>
      </div>
      <div
        class="hidden"
        id={"#{@id}-tests"}
        phx-hook="AceEditor"
        phx-update="ignore"
      ><%= Parameters.parse_tests_to_string(tests) %></div>
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
