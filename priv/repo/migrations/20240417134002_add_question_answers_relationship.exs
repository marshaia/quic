defmodule Quic.Repo.Migrations.AddQuestionAnswersRelationship do
  use Ecto.Migration

  def change do
    alter table(:question_answers) do
      add :question_id, references(:questions, on_delete: :delete_all, type: :binary_id)
    end
  end
end
