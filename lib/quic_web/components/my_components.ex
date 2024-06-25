defmodule QuicWeb.MyComponents do
  use Phoenix.Component

  alias Quic.Parameters
  alias Phoenix.LiveView.JS
  alias QuicWeb.QuicWebAux
  alias Quic.Sessions

  import QuicWeb.CoreComponents
  import Phoenix.HTML

  # import QuicWeb.Gettext


  @doc """
  Renders a box with the author information.

  ## Examples
      <.author_box username="pg12345" display_name="John Doe" />
  """
  attr :username, :string, required: true, doc: "the username of the author"
  attr :display_name, :string, required: true, doc: "the display_name of the author"

  def author_box(assigns) do
    ~H"""
    <div class="flex flex-col items-center text-center justify-center bg-[var(--background-card)] border border-[var(--border)] p-4 rounded-md gap-4 hover:bg-[--hover]">
      <p class="font-semibold"><%= @username %></p>
      <p class="text-sm"><%= @display_name %></p>
    </div>
    """
  end



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
  def side_bar_items_personal(assigns) do
    ~H"""
    <section class="mt-10 sidebar-group">
      <span class="text-sm font-semibold">PERSONAL</span>
      <%!-- PROFILE --%>
      <.link href={"/authors/profile"}
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
          <%!-- <div class={["w-4 h-4 rounded-full", (if (Map.has_key?(changes, :is_correct) && changes.is_correct) || (Map.has_key?(answer_changeset.data, :is_correct) && answer_changeset.data.is_correct), do: "bg-[var(--green)]", else: "bg-red-700")]} /> --%>
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

      <%!-- <hr class="my-5"/> --%>
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
      <%!-- <p class="mt-8 font-bold">Description</p> --%>
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
        <div class="mt-8 -mb-2 mb-5">
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

        <%!-- CODE --%>
        <.language_previewer text={code} language={language} />

      <%= if @type === :fill_the_code do %>
        <%!-- DIVIDER --%>
        <hr class="w-full mt-6 mb-4" />

        <%!-- CORECT ANSWER --%>
        <div class="flex items-center w-full gap-3">
          <.right_or_wrong is_correct={true} />
          <.language_previewer text={Parameters.put_correct_answers_in_code_changeset(@parameters_changeset)} language={language} />
        </div>
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
          <Heroicons.list_bullet class="w-5 h-5" />
          <p><%= Enum.count(@quiz.questions) %> Questions</p>
        </div>
        <div class="flex gap-1">
          <Heroicons.user class="w-5 h-5"/>
          <p><%= @quiz.author.display_name %></p>
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
            <Heroicons.trash class="w-5 h-5 text-[var(--primary-color-text)] hover:text-[var(--red)]" />
          </.link>
        </div>


        <p><%= if String.length(@quiz.description) > 100, do: String.slice(@quiz.description, 0..100) <> "...", else: @quiz.description %></p>

        <div class="flex flex-col items-center justify-between gap-2 sm:flex-row">
          <div class="flex gap-1">
            <Heroicons.list_bullet class="w-5 h-5" />
            <p class="text-gray-400"><%= Enum.count(@quiz.questions) %> Questions</p>
          </div>

          <div class="flex gap-1">
            <Heroicons.trophy class="w-5 h-5" />
            <p class="text-gray-400"><%= @quiz.total_points %> Points</p>
          </div>

          <div class="flex gap-1">
            <Heroicons.user_circle class="w-5 h-5" />
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

      <%!-- QUIZ ACTIONS --%>
      <%!-- <div class="flex flex-col items-center justify-between">
        <.link navigate={~p"/sessions/new/quiz/#{quiz.id}"}>
          <Heroicons.bolt class="question-box-icon" />
        </.link>

        <.link phx-click={JS.push("duplicate", value: %{id: quiz.id})}>
          <Heroicons.document_duplicate class="question-box-icon" />
        </.link>

        <.link :if={isOwner} phx-click={JS.push("delete", value: %{id: quiz.id})} data-confirm="Are you sure? Once deleted, it cannot be recovered!">
          <Heroicons.trash class="w-5 h-5 text-[var(--primary-color-text)] hover:text-[var(--red)]" />
        </.link>
      </div> --%>
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
            <Heroicons.trash class="w-5 h-5 text-[var(--primary-color-text)] hover:text-[var(--red)]" />
          </.link>
        </div>

        <p><%= if String.length(@team.description) > 100, do: String.slice(@team.description, 0..100) <> "...", else: @team.description %></p>

        <div class="flex flex-col items-center justify-end gap-2 sm:flex-row">
          <div class="flex gap-1">
            <Heroicons.user_group class="w-5 h-5" />
            <p class="text-gray-400"><%= Enum.count(@team.authors) %> Collaborators</p>
          </div>

          <%!-- <div class="flex gap-1">
            <Heroicons.trophy class="w-5 h-5" />
            <p class="text-gray-400"><%= Enum.count(@team.quizzes) %> Quizzes</p>
          </div> --%>
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
    <table class="w-full p-2 overflow-auto">
      <tr class="border-b border-[var(--border)] h-10">
        <th class="min-w-40 w-[25%]">Name</th>
        <th class="min-w-[10%] pr-5">Points</th>
        <th :for={question <- @questions} class="min-w-14">Q<%= question.position %></th>
      </tr>

      <tr :for={participant <- @participants} class="h-10 text-center hover:bg-[var(--hover)] hover:cursor-pointer" phx-click="clicked_participant" phx-value-id={participant.id}>
        <td><p><%= participant.name %></p></td>
        <td class="pr-5"><p><%= participant.total_points %></p></td>
        <td :for={question <- @questions} class="">
        <% answer = Enum.find(participant.answers, nil, fn a -> a.question_id === question.id end) %>
        <% has_answered = answer !== nil %>

          <div class={["flex flex-col items-center justify-center rounded-full",
            (if has_answered && answer.result === :correct, do: "bg-[var(--light-green)]",
            else: (if has_answered && answer.result === :incorrect, do: "bg-[var(--light-red)]"))
          ]}>
            <%= if has_answered && answer.result === :correct do %>
              <Heroicons.check class="w-5 h-5 text-[var(--dark-green)]"/>
            <% else %>
              <%= if has_answered && answer.result === :incorrect do %>
                <Heroicons.x_mark class="w-5 h-5 text-[var(--dark-red)]"/>
              <% else %>
                <p class="text-gray-500">--</p>
              <% end %>
            <% end %>
          </div>
        </td>
      </tr>

      <tr>
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

    <.participants_statistics participants={participants} />
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


end
