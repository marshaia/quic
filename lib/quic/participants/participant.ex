defmodule Quic.Participants.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quic.Sessions

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participants" do
    field :name, :string
    field :total_points, :integer
    field :current_question, :integer

    belongs_to :session, Quic.Sessions.Session, foreign_key: :session_id
    has_many :answers, Quic.ParticipantAnswers.ParticipantAnswer, foreign_key: :participant_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :total_points, :current_question])
    |> validate_required([:name, :total_points])
  end

  def changeset_validate(participant, attrs, code) do
    participant
    |> cast(attrs, [:name, :total_points, :current_question])
    |> validate_name(code)
    |> validate_name_length()
  end

  def validate_name(changeset, code) do
    name = get_field(changeset, :name)

    case Sessions.get_open_session_by_code(code) do
      nil -> changeset
      session ->
        other_participants = session.participants |> Enum.map(&(&1.name))
        if Enum.any?(other_participants, fn p -> p === name end) do
          add_error(changeset, :name, "there's already a Participant with that name in the Session")
        else
          changeset
        end
    end
  end

  defp validate_name_length(changeset) do
    changeset |> validate_length(:name, max: 50, message: "must have less than 50 characters")
  end

end
