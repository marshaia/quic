defmodule QuicWeb.MyComponents do
  use Phoenix.Component
  import QuicWeb.CoreComponents
  alias Phoenix.LiveView.JS

  # alias Phoenix.LiveView.JS
  # import QuicWeb.Gettext



  @doc """
  Renders a quiz box with all the basic information.

  ## Examples
      <.quiz_box quiz={@quiz} />
  """
  attr :quiz, Quic.Quizzes.Quiz, required: true, doc: "the Quiz struct"

  def quiz_box(assigns) do
    ~H"""
    <div class="p-4 bg-yellow">
      <p class="font.semibold">@quiz.name</p>
      <p class="text-xs">@quiz.description</p>
    </div>
    """
  end

  @doc """
  Renders a square box with an icon on top and some text underneath.

  ## Examples
      <.home_box icon="hero-computer-desktop" text="QUIC" />
  """
  attr :icon, :string, required: true, doc: "the heroicon to be displayed"
  attr :icon_class, :string, default: "", doc: "the heroicon classes to implement"
  attr :text, :string, required: true, doc: "the text to put underneath the icon"
  attr :text_class, :string, default: "", doc: "the text classes to implement"

  def home_box(assigns) do
    ~H"""
    <div class="flex flex-col items-center text-center justify-center bg-[var(--background-card)] border border-[var(--border)] p-4 rounded-md gap-4">
      <.icon name={@icon} class={@icon_class}/>
      <p class={@text_class}><%= @text %></p>
    </div>
    """
  end



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

      <.link href={"/authors"} class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "home"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
      <Heroicons.home class="w-4 text-xl tracking-wider md:w-7 font-extralight"/>
          <span>Home</span>
      </.link>

      <.link href={"/quizzes"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "quiz"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.pencil_square class="w-4 text-xl tracking-wider md:w-7 font-extralight"/>
          <span>Quizzes</span>
      </.link>

      <.link href={"/teams"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "team"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.users class="w-4 text-xl tracking-wider md:w-7 font-extralight"/>
          <span>Teams</span>
      </.link>

      <.link href={"/sessions"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "session"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.bolt class="w-4 text-xl tracking-wider md:w-7 font-extralight"/>
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
      <.link href={"/authors/settings"}
      class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "settings"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.cog_8_tooth class="w-4 text-xl tracking-wider md:w-7 font-extralight"/>
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
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-zinc-50/90 dark:bg-slate-900/90" aria-hidden="true" />
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
                  <.icon name="hero-x-mark-solid" class="w-5 h-5" />
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
    <div class="mt-2">
      <a href={@navigate} style="padding: 2px 8px 2px 8px; border: 2px solid black; border-radius: 25px;">
        <.icon name="hero-arrow-left-solid" class="w-4 h-4" />
        <span class="text-sm font-bold"><%= render_slot(@inner_block) %></span>
      </a>
    </div>
    """
  end


end
