defmodule Quic.Quizzes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quizzes" do
    field :name, :string
    field :description, :string
    field :total_points, :integer

    belongs_to :author, Quic.Accounts.Author, foreign_key: :author_id
    has_many :questions, Quic.Questions.Question, foreign_key: :quiz_id
    #has_many :sessions, Quic.Sessions.Session, foreign_key: :quiz_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:name, :description, :total_points])
    |> validate_required([:name, :description, :total_points])
  end

  def changeset(quiz, attrs, author) do
    quiz
    |> cast(attrs, [:name, :description, :total_points])
    |> put_assoc(:author, author)
    |> validate_required([:name, :description, :total_points])
  end
end
