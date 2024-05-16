defmodule Quic.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field :description, :string
    #field :title, :string
    field :points, :integer
    field :type, Ecto.Enum, values: [:single_choice, :multiple_choice, :true_false, :open_answer, :fill_the_blanks, :fill_the_code, :code]

    belongs_to :quiz, Quic.Quizzes.Quiz, foreign_key: :quiz_id
    has_many :answers, Quic.Questions.QuestionAnswer, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:description, :points, :type]) # :title
    |> validate_required([:description, :points, :type]) # :title
    |> validate_points()
  end

  @doc false
  def changeset(question, attrs, quiz) do
    question
    |> cast(attrs, [:description, :points, :type]) # :title
    |> put_assoc(:quiz, quiz)
    |> validate_required([:description, :points, :type]) # :title
    |> validate_points()
  end

  def validate_points(changeset) do
    changeset
    |> validate_required([:points])
    |> validate_number(:points, greater_than_or_equal_to: -1, message: "nº of points must be equal or greater than 0")
    |> validate_number(:points, less_than_or_equal_to: 1001, message: "nº of points must be equal or less than 1000")
  end
end
