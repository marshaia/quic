defmodule Quic.Repo.Migrations.CreateQuestionAnswers do
  use Ecto.Migration

  def change do
    create table(:question_answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :answer, :text
      add :is_correct, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
