defmodule Quic.Repo.Migrations.QuestionBelongsToQuiz do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :quiz_id, references(:quizzes, on_delete: :delete_all, type: :binary_id)
      add :parameter_id, references(:parameters, on_delete: :delete_all, type: :binary_id)
    end
  end
end
