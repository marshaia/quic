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


end
