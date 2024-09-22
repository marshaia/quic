defmodule QuicWeb.QuestionLive.FormFillCodeAndCode do
  use QuicWeb, :live_component

  alias Quic.Parameters

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- LANGUAGE --%>
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
      <div class="flex items-center gap-2 mt-8 mb-2">
        <p class="font-bold text-left"><%= if @type === :code, do: "Participant Template", else: "Question Code" %></p>

        <% code_id = if @responsive, do: "code-tooltip-responsive", else: "code-tooltip" %>
        <.tooltip tooltip_id={code_id} class={"w-[300px] #{if @type === :code, do: "-top-24 -left-32", else: "-top-32 -left-28"}"}>
          <p class="text-xs">
            <%= if @type === :fill_the_code do %>
              This is the code to be completed by the Participants.
              To declare a completion segment, insert <code>{{id}}</code> in the intended place.
            <% else %>
              This is the code template that will be shown to the Participants.
            <% end %>
            Don't forget to include/import the needed packages.
          </p>
        </.tooltip>
      </div>
      <.code_editor editor_id={"#{@id}-code"} loading={@loading} text={if Map.has_key?(@changeset.changes, :code), do: @changeset.changes.code, else: (if Map.has_key?(@changeset.data, :code), do: @changeset.data.code, else: "")} />

      <%!-- CORRECT ANSWERS --%>
      <%= if @type === :fill_the_code do %>
        <% answer = (if Map.has_key?(@changeset.changes, :correct_answers), do: @changeset.changes.correct_answers, else: (if Map.has_key?(@changeset.data, :correct_answers), do: @changeset.data.correct_answers, else: %{})) %>

        <div class="flex items-center gap-2 mt-8 mb-2">
          <p class="font-bold text-left">Correct Answers</p>

          <% answers_id = if @responsive, do: "correct-answers-tooltip-responsive", else: "correct-answers-tooltip" %>
          <.tooltip tooltip_id={answers_id} class={"-left-32 w-[300px] -top-24"}>
            <p class="text-xs">Here you enter the correspondence between the <code>ids</code> defined above and the correct answers. Like so <code>id:int a</code></p>
          </.tooltip>
        </div>
        <.code_editor editor_id={"#{@id}-answers"} loading={@loading} text={Parameters.parse_correct_answers_to_string(answer)} />
      <% end %>

      <hr class="w-full mt-10 mb-5"/>

      <%!-- TEST FILE --%>
      <div class="flex items-center gap-2 mt-8 mb-2">
        <p class="font-bold text-left">Test File</p>
        <% test_file_id = if @responsive, do: "test-file-tooltip-responsive", else: "test-file-answers-tooltip" %>
        <.tooltip tooltip_id={test_file_id} class={"-left-16 w-[300px] -top-56"}>
          <p class="text-xs">Here you enter the code to test the Participant's submission.</p>
          <p class="text-xs">When using <b>C</b>, don't forget to define the function's header so that it uses the function defined by the Participant when compiled, like so: <code>int sum(int a, int b);</code></p>
          <p class="text-xs">You also have to capture the arguments via stdin, so use functions like <code>scanf</code>, <code>fgets</code>, etc.</p>
          <p class="text-xs">When using <b>Python</b>, dont' forget to retrieve the test arguments using <code>sys</code> or <code>argparse</code>.</p>
        </.tooltip>
      </div>
      <.code_editor editor_id={"#{@id}-test-file"} loading={@loading} text={if Map.has_key?(@changeset.changes, :test_file), do: @changeset.changes.test_file, else: (if Map.has_key?(@changeset.data, :test_file), do: @changeset.data.test_file, else: "")} />

      <%!-- TESTS --%>
      <% tests = (if Map.has_key?(@changeset.changes, :tests), do: @changeset.changes.tests, else: (if Map.has_key?(@changeset.data, :tests), do: @changeset.data.tests, else: [])) %>
      <div class="flex items-center gap-2 mt-8 mb-2">
        <p class="font-bold text-left">Tests</p>
        <% tests_id = if @responsive, do: "tests-tooltip-responsive", else: "tests-answers-tooltip" %>
        <.tooltip tooltip_id={tests_id} class={"-left-12 w-[300px] -top-48"}>
          <p class="text-xs">Here you enter the tests to assess the code submitted by the Participants.</p>
          <p class="text-xs">Follow the syntax <code>input:output</code>. To insert multiple inputs, simply separate them with commas, like this: <code>1,2:3</code></p>
          <p class="text-xs">You can enter null inputs or outputs by leaving them empty, like this <code>:4</code> or this <code>3,-1:</code></p>
          <p class="text-xs">Strings don't need (double) quotes: <code>hello:Hello World</code></p>
        </.tooltip>
      </div>
      <.code_editor editor_id={"#{@id}-tests"} loading={@loading} text={Parameters.parse_tests_to_string(tests)} />
    </div>
    """
  end

  @impl true
  def update(%{loading: loading, parameters: parameters, type: type, id_editor: id} = assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket
        |> assign(:loading, loading)
        |> assign(:responsive, String.contains?(id, "responsive"))
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
