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
    field :current_question, :integer
    field :immediate_feedback, :boolean, default: false
    field :final_feedback, :boolean, default: false

    embeds_one :quiz, Quic.Quizzes.EmbeddedQuiz

    has_many :participants, Quic.Participants.Participant, foreign_key: :session_id
    belongs_to :monitor, Quic.Accounts.Author, foreign_key: :monitor_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:code, :start_date, :end_date, :status, :type, :current_question, :immediate_feedback, :final_feedback])
    |> validate_required([:type])
  end
end
