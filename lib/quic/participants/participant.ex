defmodule Quic.Participants.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participants" do
    field :name, :string
    field :total_points, :integer
    field :current_question, :integer

    belongs_to :session, Quic.Sessions.Session, foreign_key: :session_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :total_points, :current_question])
    |> validate_required([:name, :total_points, :current_question])
  end
end
