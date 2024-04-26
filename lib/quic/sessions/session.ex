defmodule Quic.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    field :code, :string
    field :status, Ecto.Enum, values: [:open, :on_going, :closed]
    field :type, Ecto.Enum, values: [:monitor_paced, :participant_paced]
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime

    has_many :participants, Quic.Participants.Participant, foreign_key: :session_id
    belongs_to :monitor, Quic.Accounts.Author, foreign_key: :monitor_id
    belongs_to :quiz, Quic.Quizzes.Quiz, foreign_key: :quiz_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:code, :start_date, :end_date, :status, :type])
    #|> validate_required([:code, :start_date, :end_date, :status, :type])
    |> validate_required([:type])
  end
end
