defmodule Quic.Quizzes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quizzes" do
    field :name, :string
    field :description, :string
    field :total_points, :integer
    field :public, :boolean

    belongs_to :author, Quic.Accounts.Author, foreign_key: :author_id
    has_many :questions, Quic.Questions.Question, foreign_key: :quiz_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:name, :description, :total_points, :public])
    |> validate_required([:name, :description, :total_points, :public])
    |> validate_name()
  end

  def changeset(quiz, attrs, author) do
    quiz
    |> cast(attrs, [:name, :description, :total_points, :public])
    |> put_assoc(:author, author)
    |> validate_required([:name, :description, :total_points, :public])
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 255, message: "must have less than 256 characters")
  end
end
