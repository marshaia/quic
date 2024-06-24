defmodule Quic.Quizzes.EmbeddedQuiz do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :description, :string
    field :total_points, :integer
    field :author_id, :string
    field :author_name, :string

    embeds_many :questions, Quic.Questions.Question
    embeds_many :parameters, Quic.Parameters.Parameter
    embeds_many :answers, Quic.Questions.QuestionAnswer
  end

  @doc false
  def changeset(quiz, attrs, questions, answers, parameters) do
    quiz
    |> cast(attrs, [:name, :description, :total_points, :author_id, :author_name])
    |> put_embed(:questions, questions)
    |> put_embed(:answers, answers)
    |> put_embed(:parameters, parameters)
    |> validate_required([:name, :description, :total_points, :author_id, :author_name])
  end
end
