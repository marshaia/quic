defmodule Quic.ParticipantAnswers.ParticipantAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participant_answers" do
    field :result, Ecto.Enum, values: [:correct, :incorrect, :assessing, :error]
    field :error_reason, :string
    field :answer, {:array, :string}
    field :question_id, :string

    belongs_to :participant, Quic.Participants.Participant, foreign_key: :participant_id
    #belongs_to :question, Quic.Questions.Question, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant_answer, attrs) do
    participant_answer
    |> cast(attrs, [:answer, :result, :question_id, :error_reason])
    |> validate_required([:answer, :result, :question_id])
  end

  @doc false
  def changeset(participant_answer, attrs, participant) do
    participant_answer
    |> cast(attrs, [:answer, :result, :question_id, :error_reason])
    |> put_assoc(:participant, participant)
    |> validate_required([:answer, :result, :question_id])
  end
end
