defmodule Quic.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "teams" do
    field :name, :string
    field :description, :string

    many_to_many :authors, Quic.Accounts.Author, join_through: "teams_authors"
    many_to_many :quizzes, Quic.Quizzes.Quiz, join_through: "teams_quizzes"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> validate_name()
  end

  @doc false
  def changeset(team, attrs, author) do
    team
    |> cast(attrs, [:name, :description])
    |> put_assoc(:authors, [author])
    |> validate_required([:name, :description])
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset |> validate_length(:name, max: 255, message: "must have less than 256 characters")
  end
end
