defmodule QuicWeb.MyComponents do
  use Phoenix.Component
  import QuicWeb.CoreComponents

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
      <Heroicons.home class="hidden text-xl tracking-wider w-7 md:flex font-extralight"/>
          <span>Home</span>
      </.link>

      <.link href={"/quizzes"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "quiz"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.pencil class="hidden text-xl tracking-wider w-7 md:flex font-extralight"/>
          <span>Quizzes</span>
      </.link>

      <.link href={"/teams"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "team"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.users class="hidden text-xl tracking-wider w-7 md:flex font-extralight"/>
          <span>Teams</span>
      </.link>

      <.link href={"/sessions"}
        class={["sidebar-item", (if String.contains?(String.downcase(@page_title), "session"), do: "text-[var(--primary-color)]", else: "text-[var(--primary-color-text)]")]}>
        <Heroicons.bolt class="hidden text-xl tracking-wider w-7 md:flex font-extralight"/>
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
        <Heroicons.cog_8_tooth class="hidden text-xl tracking-wider w-7 h-7 md:flex font-extralight"/>
        <span>Settings</span>
      </.link>
    </section>
    """
  end


end
