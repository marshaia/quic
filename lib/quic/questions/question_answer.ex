defmodule Quic.Questions.QuestionAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "question_answers" do
    field :answer, :string
    field :is_correct, :boolean, default: false

    belongs_to :question, Quic.Questions.Question, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question_answer, attrs) do
    question_answer
    |> cast(attrs, [:answer, :is_correct])
    |> validate_required([:answer, :is_correct])
  end
end
