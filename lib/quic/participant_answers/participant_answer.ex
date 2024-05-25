defmodule Quic.ParticipantAnswers.ParticipantAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participant_answers" do
    field :result, Ecto.Enum, values: [:correct, :incorrect, :assessing]
    field :answer, {:array, :string}

    belongs_to :participant, Quic.Participants.Participant, foreign_key: :participant_id
    belongs_to :question, Quic.Questions.Question, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant_answer, attrs) do
    participant_answer
    |> cast(attrs, [:answer, :result])
    |> validate_required([:answer, :result])
  end

  @doc false
  def changeset(participant_answer, attrs, participant, question) do
    participant_answer
    |> cast(attrs, [:answer, :result])
    |> put_assoc(:participant, participant)
    |> put_assoc(:question, question)
    |> validate_required([:answer, :result])
  end
end
