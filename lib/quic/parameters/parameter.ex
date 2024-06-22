defmodule Quic.Parameters.Parameter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "parameters" do
    field :code, :string
    field :language, Ecto.Enum, values: [:c]
    field :correct_answers, :map
    field :tests, {:array, :map}

    belongs_to :question, Quic.Questions.Question, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end


  @doc false
  def changeset(parameter, attrs) do
    parameter
    |> cast(attrs, [:code, :language, :correct_answers, :tests])
    |> validate_required([:code, :language, :correct_answers, :tests])
  end

end
