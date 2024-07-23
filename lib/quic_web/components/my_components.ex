defmodule QuicWeb.MyComponents do
  use Phoenix.Component

  alias Quic.{Sessions, Parameters}
  alias Phoenix.LiveView.JS
  alias QuicWeb.QuicWebAux

  import QuicWeb.CoreComponents
  import Phoenix.HTML


  attr :page_title, :string, required: true, doc: "title of the current page"
  def side_bar_items_general(assigns) do
    ~H"""
    <div class="sidebar-group">
      <span class="text-sm font-semibold">GENERAL</span>

      <.link href={"/authors"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "home"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.home class="sidebar-icon"/>
          <span>Home</span>
      </.link>

      <.link href={"/quizzes"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "quiz"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.pencil_square class="sidebar-icon"/>
          <span>Quizzes</span>
      </.link>

      <.link href={"/teams"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "team"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.users class="sidebar-icon"/>
          <span>Teams</span>
      </.link>

      <.link href={"/sessions"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "session"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.bolt class="sidebar-icon"/>
          <span>Sessions</span>
      </.link>
    </div>
    """
  end


  attr :page_title, :string, required: true, doc: "the current page title"
  attr :current_author, :any, default: %{}

  def side_bar_items_personal(assigns) do
    ~H"""
    <section class="mt-10 sidebar-group">
      <span class="text-sm font-semibold">PERSONAL</span>
      <%!-- PROFILE --%>
      <.link href={"/authors/profile/#{@current_author.id}"}
      class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "profile"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.user class="sidebar-icon"/>
        <span>Profile</span>
      </.link>

      <%!-- SETTINGS --%>
      <.link href={"/authors/settings"}
      class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "settings"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.cog_8_tooth class="sidebar-icon"/>
        <span>Settings</span>
      </.link>
    </section>
    """
  end


  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def sidebar_responsive(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-zinc-400/90 dark:bg-slate-900/90" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex items-center justify-center min-h-full">
          <div class="p-10 w-80 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden transition bg-[var(--background-card)] shadow-lg shadow-zinc-700/10 ring-zinc-700/10 rounded-2xl"
            >
              <%!-- CANCEL BUTTON --%>
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
                  aria-label="close"
                >
                  <Heroicons.x_mark class="w-5 h-5" />
                </button>
              </div>
              <div id={"#{@id}-content"} class="p-14">
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end




  @doc """
  Renders a back navigation link.

  ## Examples

      <.my_back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def my_back(assigns) do
    ~H"""
    <div>
      <a href={@navigate} class="flex items-center gap-2 px-2 py-1.5 border border-[var(--primary-color-text)] rounded-full hover:bg-[var(--hover)]">
        <Heroicons.arrow_left class="w-4 h-4" />
        <span class="text-sm font-medium"><%= render_slot(@inner_block) %></span>
      </a>
    </div>
    """
  end


  @doc """
  Renders a markdown previewer block.

  ## Examples

      <.markdown text="your markdown text here" />
  """
  attr :text, :string, default: ""
  attr :class, :string, default: ""

  def markdown(assigns) do
    ~H"""
    <div class={"space-y-2 leading-relaxed #{@class}"}>
      <%= String.trim(@text) |> Earmark.as_html!(code_class_prefix: "lang- language-") |> raw %>
    </div>
    """
  end



  @doc """
  Renders a language previewer block.

  ## Examples

      <.language_previewer text="your code here" langugage="c" />
      <.language_previewer text="your code here" langugage="c" class="mt-20" />
  """
  attr :text, :string, default: ""
  attr :class, :string, default: ""
  attr :language, :string, default: ""

  def language_previewer(assigns) do
    text = assigns.text |> String.replace(~r/{{(\w+)}}/, "__\\1__")
    assigns = Map.put(assigns, :text, text)

    ~H"""
    <div class={"w-full #{@class}"}>
      <pre><code class={"lang-#{@language} language-#{@language}"}><%= @text %></code></pre>
    </div>
    """
  end


  @doc """
  Renders a True or False block

  ## Examples

    <.true_or_false is_true={true} />
  """
  attr :is_true, :boolean, default: false
  attr :class, :string, default: ""

  def true_or_false(assigns) do
    ~H"""
    <div class={@class}>
      <%= if @is_true do %>
        <div class="-ml-2 px-2 rounded-md py-1 bg-[var(--light-green)] w-min">
          <p class="text-[var(--dark-green-2)]">True</p>
        </div>

      <% else %>
        <div class="-ml-2 px-2 rounded-md py-1 bg-[var(--light-red)] w-min">
          <p class="text-[var(--dark-red)]">False</p>
        </div>
      <% end %>
    </div>
    """
  end



  @doc"""
  Renders a right or wing square.

  ## Examples.
    <.right_or_wrong is_correct={true} />
  """
  attr :is_correct, :boolean, default: false
  attr :class, :string, default: ""

  def right_or_wrong(assigns) do
    ~H"""
    <div class={["p-1 rounded-lg #{@class}", (if @is_correct, do: "dark:bg-[var(--dark-green)] bg-[var(--light-green)]", else: "dark:bg-[var(--dark-red)] bg-[var(--light-red)]")]}>
      <%= if @is_correct do %>
        <Heroicons.check class="w-4 h-4 dark:text-[var(--light-green)] text-[var(--dark-green)]"/>
      <% else %>
        <Heroicons.x_mark class="w-4 h-4 dark:text-[var(--light-red)] text-[var(--dark-red)]"/>
      <% end %>
    </div>
    """
  end


  @doc"""
  Renders a blank answer square.

  ## Examples.
    <.blank_square class="..." />
  """
  attr :class, :string, default: ""

  def blank_square(assigns) do
    ~H"""
    <div class={"p-1 rounded-lg bg-[var(--border)] #{@class}"}>
    </div>
    """
  end





  @doc """
  Renders a Markdown Previewer for a Question's Answers.

  ## Examples

    <.markdown_previewer  answers={question.answers}/>
  """
  attr :answers, :any, default: []
  attr :type, :atom, default: :open_answer

  def markdown_previewer_answers(assigns) do
    ~H"""
    <div
      :for={{answer_changeset, index} <- Enum.with_index(@answers)}
      class={["bg-[var(--background-card)]", (if index !== 0, do: "border-t border-[var(--border)]")]}
    >
      <% changes = answer_changeset.changes %>
      <div class="flex my-3">
        <div class="flex flex-col items-center justify-center">
          <.right_or_wrong is_correct={(Map.has_key?(changes, :is_correct) && changes.is_correct) || (Map.has_key?(answer_changeset.data, :is_correct) && answer_changeset.data.is_correct)} class="w-6 h-6 min-h-6 min-w-6" />
        </div>

        <div class="flex-1 overflow-auto">
          <div class="flex-1 px-2 mx-3">
            <%= if Map.has_key?(changes, :answer) do %>
              <%= if @type === :fill_the_code || @type === :code do %>
                <.language_previewer text={changes.answer} language="c" />
              <% else %>
                <.markdown text={changes.answer} />
              <% end %>
            <% else %>
              <%= if answer_changeset.data.answer !== nil do %>
                <%= if @type === :fill_the_code || @type === :code do %>
                  <.language_previewer text={answer_changeset.data.answer} language="c" />
                <% else %>
                  <.markdown text={answer_changeset.data.answer} />
                <% end %>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end




  @doc """
  Renders a Markdown Previewer for a Question.

  ## Examples

    <.markdown_previewer_question type={question.type} answers={question.answers} question_changeset={changeset} />
  """
  attr :answers, :any, default: []
  attr :type, :atom, required: true
  attr :question_changeset, :any, default: %{}
  attr :class, :string, default: ""
  attr :parameters_changeset, :any, default: %{}

  def markdown_previewer_question(assigns) do
    ~H"""
    <div class={"#{@class}"}>
      <%!-- QUESTION TYPE AND POINTS --%>
      <div class="flex justify-between mt-8">
        <div class={["py-1 px-2 rounded-md", (if is_atom(@type), do: QuicWebAux.get_type_color(@type), else: QuicWebAux.get_type_color(String.to_atom(@type)))]}>
          <p class="text-white"><%= (if is_atom(@type), do: QuicWebAux.readable_name(@type), else: QuicWebAux.readable_name(String.to_atom(@type))) %></p>
        </div>

        <div class="flex items-center gap-2">
          <Heroicons.trophy class="w-5 h-5 text-[var(primary-color-text)]" />
          <p>
            <%= if Map.has_key?(@question_changeset.changes, :points) do %>
              <%= @question_changeset.changes.points %>
            <% else %>
              <%= if @question_changeset.data.points !== nil do %>
                <%= @question_changeset.data.points %>
              <% end %>
            <% end %>
            Points
          </p>
        </div>
      </div>

      <%!-- QUESTION DESCRIPTION --%>
      <div class="mt-5 mb-8 bg-[var(--background-card)] rounded-md">
        <%= if Map.has_key?(@question_changeset.changes, :description) do %>
          <.markdown text={@question_changeset.changes.description} />
        <% else %>
          <%= if @question_changeset.data.description !== nil do %>
            <.markdown text={@question_changeset.data.description} />
          <% end %>
        <% end %>
      </div>

      <div :if={@type === :fill_the_code || @type === :code} class="-mt-3">
        <.fill_code_previewer parameters_changeset={@parameters_changeset} type={@type}/>
      </div>

      <%= if @type === :true_false do %>
        <% answer = Enum.at(@answers, 0, nil) %>
        <hr />
        <.true_or_false
          class="my-3 ml-2"
          is_true={(Map.has_key?(answer.changes, :is_correct) && answer.changes.is_correct) || (Map.has_key?(answer.data, :is_correct) && answer.data.is_correct)}
        />
      <% end %>

      <%= if @type === :fill_the_blanks || @type === :single_choice || @type === :multiple_choice do %>
        <div class="mt-8 mb-5 -mb-2">
          <p class="font-bold">Answers</p>
        </div>

        <.markdown_previewer_answers answers={@answers} type={@type}/>
      <% end %>
    </div>
    """
  end


  @doc"""
  Renders a Fill the Code and Code question types Parameters.

  ## Examples:

    <.fill_code_previewer />
  """
  attr :parameters_changeset, :any, default: %{}
  attr :type, :atom, default: :code

  def fill_code_previewer(assigns) do
    ~H"""
    <div class="w-full">
      <% language = (if Map.has_key?(@parameters_changeset.changes, :language), do: Atom.to_string(@parameters_changeset.changes.language), else: (if @parameters_changeset.data.language !== nil, do: Atom.to_string(@parameters_changeset.data.language), else: "c")) %>
      <% code = (if Map.has_key?(@parameters_changeset.changes, :code), do: @parameters_changeset.changes.code, else: (if @parameters_changeset.data.code !== nil, do: @parameters_changeset.data.code, else: "")) %>
      <% tests = (if Map.has_key?(@parameters_changeset.changes, :tests), do: @parameters_changeset.changes.tests, else: (if @parameters_changeset.data.tests !== nil, do: @parameters_changeset.data.tests, else: [])) %>

      <%!-- CODE --%>
      <.language_previewer :if={String.length(code) > 0} text={code} language={language} />
      <hr class="w-full mt-7" />

      <%= if @type === :fill_the_code do %>
        <%!-- DIVIDER --%>
        <h6 class="mt-5 text-base">Correct Answer</h6>

        <%!-- CORRECT ANSWER --%>
        <div class="flex items-center w-full gap-3">
          <.right_or_wrong is_correct={true} />
          <.language_previewer text={Parameters.put_correct_answers_in_code_changeset(@parameters_changeset)} language={language} />
        </div>
      <% end %>

      <%!-- TESTS --%>
      <h6 class="mt-8 mb-2 text-base">Tests</h6>
      <%= if Enum.count(tests) === 0 do %>
        <p class="-mt-2 text-gray-500 dark:text-gray-400">Nothing to show</p>
      <% else %>
        <table class="w-full p-2 overflow-auto">
          <tr class="border-y border-[var(--border)] h-8">
            <th class="w-1/2 min-w-max"><p>Input</p></th>
            <th class="min-w-8"></th>
            <th class="w-1/2 min-w-max"><p>Output</p></th>
          </tr>

          <tr :for={test <- tests} class="h-8 text-center">
            <td><p><%= if test["input"], do: test["input"], else: "Empty" %></p></td>
            <td class="flex items-center justify-center mt-2"><Heroicons.arrow_right_circle class="w-5 h-5 stroke-1" /></td>
            <td><p><%= if test["output"], do: test["output"], else: "Empty" %></p></td>
          </tr>
        </table>
      <% end %>
    </div>
    """
  end


  @doc """
  Renders a Quiz Summary block with the basic information.

  ## Examples:

    <.quiz_summary quiz={@quiz}/>
  """
  attr :quiz, :any, default: %{}

  def quiz_summary(assigns) do
    ~H"""
    <div phx-click="clicked_quiz" phx-value-id={@quiz.id}>
      <p class="-mt-1 text-base font-semibold text-[var(--primary-color-text)]"><%= if String.length(@quiz.name) > 25, do: String.slice(@quiz.name, 0..25) <> "...", else: @quiz.name %></p>
      <p><%= if String.length(@quiz.description) > 50, do: String.slice(@quiz.description, 0..50) <> "...", else: @quiz.description %></p>
      <div class="flex justify-between gap-2 mt-4">
        <div class="flex gap-1">
          <Heroicons.list_bullet class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400" />
          <p class="text-gray-500 dark:text-gray-400"><%= Enum.count(@quiz.questions) %> Questions</p>
        </div>
        <div class="flex gap-1">
          <Heroicons.user class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400"/>
          <p class="text-gray-500 dark:text-gray-400"><%= @quiz.author.display_name %></p>
        </div>
      </div>
    </div>
    """
  end


  @doc """
  Renders a quiz box with name, description, nº of questions, points, author name and delete option.

  ## Examples:
    <.quiz_box quiz={@quiz}/>
  """
  attr :index, :integer, default: 1
  attr :quiz, :any, default: %{}
  attr :isOwner, :boolean, default: false
  attr :current_author_id, :string, default: ""

  def quiz_box(assigns) do
    ~H"""
    <div class="w-full h-full hover:cursor-pointer hover:bg-[var(--hover)] flex rounded-md border border-[var(--border)] bg-[var(--background-card)] py-2 px-4 min-h-32 mb-4" phx-click="clicked_quiz" phx-value-id={@quiz.id}>
      <%!-- QUIZ INFO --%>
      <div class="flex flex-col justify-between flex-1">
        <div class="flex justify-between">
          <div class="flex items-center gap-2">
            <Heroicons.pencil_square class={["h-5 w-5", QuicWebAux.user_color(@index)]} />
            <h6 class="font-medium"><%= if String.length(@quiz.name) > 15, do: String.slice(@quiz.name, 0..15) <> "...", else: @quiz.name %></h6>
          </div>

          <.link :if={@isOwner} phx-click={JS.push("delete", value: %{id: @quiz.id})} data-confirm="Are you sure? Once deleted, it cannot be recovered!">
            <Heroicons.trash class="w-5 h-5 stroke-1 text-[var(--primary-color-text)] hover:text-[var(--red)]" />
          </.link>
        </div>

        <p><%= if String.length(@quiz.description) > 100, do: String.slice(@quiz.description, 0..100) <> "...", else: @quiz.description %></p>

        <div class="flex flex-col items-center justify-between gap-2 sm:flex-row">
          <div class="flex gap-1">
            <Heroicons.eye :if={@quiz.public} class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400"/>
            <Heroicons.eye_slash :if={!@quiz.public} class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400"/>
            <p class="text-gray-400"><%= if @quiz.public, do: "Public", else: "Private" %></p>
          </div>

          <div class="flex gap-1">
            <Heroicons.trophy class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400" />
            <p class="text-gray-400"><%= @quiz.total_points %> Points</p>
          </div>

          <div class="flex gap-1">
            <Heroicons.user_circle class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400" />
            <p class="text-gray-400">
              <%= if @quiz.author.id === @current_author_id do %>
                You
              <% else %>
                <%= @quiz.author.display_name %>
              <% end %>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end


  @doc """
  Renders a team box with name, description, nº of collaborators, etc.

  ## Examples:
    <.team_box team={@team}/>
  """
  attr :index, :integer, default: 1
  attr :team, :any, default: %{}

  def team_box(assigns) do
    ~H"""
    <div class="w-full h-full hover:cursor-pointer hover:bg-[var(--hover)] flex rounded-md border border-[var(--border)] bg-[var(--background-card)] py-2 px-4 min-h-24 mb-4" phx-click="clicked_team" phx-value-id={@team.id}>
      <div class="flex flex-col justify-between flex-1">
        <div class="flex justify-between">
          <div class="flex items-center gap-2">
            <Heroicons.users class={["h-5 w-5", QuicWebAux.user_color(@index)]} />
            <h6 class="font-medium"><%= if String.length(@team.name) > 15, do: String.slice(@team.name, 0..15) <> "...", else: @team.name %></h6>
          </div>

          <.link phx-click={JS.push("delete", value: %{id: @team.id})} data-confirm="Are you sure? Once deleted, it cannot be recovered!">
            <Heroicons.trash class="w-5 h-5 stroke-1 text-[var(--primary-color-text)] hover:text-[var(--red)]" />
          </.link>
        </div>

        <p><%= if String.length(@team.description) > 100, do: String.slice(@team.description, 0..100) <> "...", else: @team.description %></p>

        <div class="flex justify-end">
          <div class="flex gap-1">
            <Heroicons.user_group class="w-5 h-5 text-gray-500 stroke-1 dark:text-gray-400" />
            <p class="text-gray-400"><%= Enum.count(@team.authors) %> Collaborators</p>
          </div>
        </div>
      </div>
    </div>
    """
  end


  @doc """
  Renders a horizontal progress bar.

  ## Examples:

    <.participant_progress_bar progress={80} current_question={1} num_quiz_questions={10} />
    <.participant_progress_bar progress={80} current_question={1} num_quiz_questions={10} class="mt-10" />
  """
  attr :current_question, :integer, default: 0
  attr :num_quiz_questions, :integer, default: 0
  attr :progress, :float, default: 0.0
  attr :class, :string, default: ""

  def participant_progress_bar(assigns) do
    ~H"""
    <div class={"flex items-center justify-center w-full gap-2 #{@class}"}>
      <div class="bg-[var(--border)] rounded-full w-[80%]">
        <div class={["gradient text-white py-0.5 text-right rounded-full", (if @current_question !== 0, do: "px-4" )]} style={"width: #{@progress}%"}
        >
          <p class={["text-white",(if @current_question === 0, do: "py-2")]}><%= if @current_question === @num_quiz_questions, do: "Completed", else: (if @current_question > 0, do: @current_question) %></p>
        </div>
      </div>
      <p :if={@current_question !== @num_quiz_questions}><%= @num_quiz_questions %></p>
    </div>
    """
  end


  @doc """
  Renders quiz statistics in a session.

  ## Examples:

    <.participants_statistics participants={participants} />
  """
  attr :participants, :any, default: []
  attr :questions, :any, default: []
  attr :session, :string, default: ""

  def participants_statistics(assigns) do
    ~H"""
    <table id="participant_statistics_table" class="w-full p-2 overflow-auto">
      <tr class="border-b border-[var(--border)] h-10">
        <th class="min-w-40 w-[25%]">Name</th>
        <th class="min-w-[10%] pr-5">Points</th>
        <th :for={question <- @questions} class="min-w-14">Q<%= question.position %></th>
      </tr>

      <tr :for={participant <- @participants} class="h-8 text-center align-center hover:bg-[var(--hover)] hover:cursor-pointer" phx-click="clicked_participant" phx-value-id={participant.id}>
        <td><p class="flex flex-col items-center justify-center"><%= participant.name %></p></td>
        <td class="pr-5"><p class="flex flex-col items-center justify-center"><%= participant.total_points %></p></td>
        <td :for={question <- @questions}>
          <% answer = Enum.find(participant.answers, nil, fn a -> a.question_id === question.id end) %>
          <% has_answered = answer !== nil %>

          <div class={["flex flex-col items-center justify-center rounded-full",
            (if has_answered && answer.result === :correct, do: "bg-[var(--light-green)]",
            else: (if has_answered, do: "bg-[var(--light-red)]"))
          ]}>
            <%= if has_answered && answer.result === :correct do %>
              <Heroicons.check class="w-5 h-5 text-[var(--dark-green)]"/>
            <% else %>
              <%= if has_answered do %>
                <Heroicons.x_mark class="w-5 h-5 text-[var(--dark-red)]"/>
              <% else %>
                <p class="text-gray-500">--</p>
              <% end %>
            <% end %>
          </div>
        </td>
      </tr>

      <tr class="h-8 border-t border-[var(--border)]">
        <td></td>
        <td><p class="font-bold text-right">Accuracy:</p></td>
        <td :for={question <- @questions}>
          <p class="text-center"><%= Sessions.calculate_quiz_question_accuracy(@session, question.id) %>%</p>
        </td>
      </tr>
    </table>
    """
  end


  @doc """
  Renders a doughnut chart with the points and labels passed.

  ## Examples:

    <.doughnut_chart id="id" points={[10,20,30]} labels={[label1, label2, label3]} />
  """
  attr :id, :string, default: ""
  attr :points, :any, default: []
  attr :labels, :any, default: []

  def doughnut_chart(assigns) do
    ~H"""
    <div class="h-24">
      <canvas
        id={@id}
        phx-hook="ChartJS"
        data-points={Jason.encode!(@points)}
        data-labels={Jason.encode!(@labels)}
      ></canvas>
    </div>
    """
  end


  @doc"""
  Renders an Ace Editor component.

  ## Examples:

    <.code_editor editor_id="editor_1" text="int a ..." loading={false} />
  """
  attr :editor_id, :string, default: ""
  attr :text, :string, default: ""
  attr :loading, :boolean, default: false

  def code_editor(assigns) do
    ~H"""
    <div>
      <div :if={@loading} id={"#{@editor_id}-loading"}>
        <div class="flex items-center justify-center gap-3">
          <Heroicons.arrow_path class="w-5 h-5 text-[var(--primary-color)] animate-spin"/>
          <p>Loading editor</p>
        </div>
      </div>
      <div
        class="hidden"
        id={@editor_id}
        phx-hook="AceEditor"
        phx-update="ignore"
      ><%= @text %></div>
    </div>
    """
  end


  @doc"""
  Renders a Tooltip.

  ## Examples:

    <.tooltip tooltip_id="id1">
      <p>This is a tooltip</p>
    </.tooltip>
  """
  attr :tooltip_id, :string, default: ""
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <div>
      <div class="cursor-pointer" phx-click={JS.toggle(to: "#" <> @tooltip_id)}>
        <Heroicons.information_circle class="w-5 h-5 hover:text-[var(--primary-color)]" />
      </div>

      <div class="relative">
        <div id={@tooltip_id}hidden class={"absolute z-10 bg-[var(--background-view)] border border-[var(--primary-color)] px-4 py-2 rounded-xl select-none shadow-lg #{@class}"}>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end



  @doc"""
  Renders a Participant Leaderboard (in the context of a Session).

  ## Examples:

    <.leaderboard participants={participants} total_questions={10} />
  """
  attr :participants, :any, default: []
  attr :total_questions, :integer, default: 0

  def leaderboard(assigns) do
    ~H"""
    <div class="w-full">
      <table class="w-full p-2 overflow-auto">
        <tr class="border-b border-[var(--border)] h-10">
          <th class="min-w-6">#</th>
          <th class="min-w-40 w-[45%]">Name</th>
          <th class="min-w-20 md:min-w-24">Points</th>
          <th class="hidden min-w-28 sm:block sm:mt-1.5">Progress</th>
        </tr>

        <tr :for={{participant, index} <- Enum.with_index(@participants)} class="h-10 text-center">
          <td class="text-[var(--second-color)] font-bold"><%= index + 1 %></td>
          <td><p><%= participant.name %></p></td>
          <td><p><%= participant.total_points %></p></td>
          <td><p class="hidden text-gray-400 sm:block dark:text-gray-500"><%= participant.current_question %>/<%= @total_questions %></p></td>
        </tr>
      </table>
    </div>

    """
  end


  @doc """
  Renders a download button that is replaced with a loading svg when the download is active.

  ## Examples:

    <.download downloading={@loading} />
  """

  attr :downloading, :boolean, default: false

  def download(assigns) do
    ~H"""
    <button :if={@downloading === false} phx-click="download" class="p-1 px-2 rounded-full hover:bg-[var(--border)]">
      <Heroicons.arrow_down_tray class="w-4 h-4 stroke-1 text-[var(--primary-color-text)]" />
    </button>

    <div :if={@downloading === true} role="status" class="pr-2">
      <svg aria-hidden="true" class="w-5 h-5 animate-spin text-[var(--border)] fill-[var(--primary-color)]" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="currentColor"/>
          <path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentFill"/>
      </svg>
      <span class="sr-only">Loading...</span>
    </div>
    """
  end

end
