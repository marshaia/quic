defmodule Quic.Repo.Migrations.SessionRelationships do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :monitor_id, references(:authors, on_delete: :delete_all, type: :binary_id)
      add :quiz_id, references(:quizzes, on_delete: :delete_all, type: :binary_id)
    end
  end
end
