defmodule Quic.Quizzes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quizzes" do
    field :name, :string
    field :description, :string
    field :total_points, :integer

    belongs_to :author, Quic.Quizzes.Quiz, foreign_key: :author_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:name, :description, :total_points])
    |> validate_required([:name, :description, :total_points])
  end
end
