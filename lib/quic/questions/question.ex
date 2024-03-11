defmodule Quic.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field :description, :string
    field :title, :string
    field :points, :integer

    belongs_to :quiz, Quic.Quizzes.Quiz, foreign_key: :quiz_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:title, :description, :points])
    |> validate_required([:title, :description, :points])
    |> validate_points()
  end

  @doc false
  def changeset(question, attrs, quiz) do
    question
    |> cast(attrs, [:title, :description, :points])
    |> put_assoc(:quiz, quiz)
    |> validate_required([:title, :description, :points])
    |> validate_points()
  end

  def validate_points(changeset) do
    changeset
    |> validate_required([:points])
    |> validate_number(:points, greater_than: -1, message: "question points must be equal or greater than 0")
  end
end