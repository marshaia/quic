defmodule Quic.Repo.Migrations.QuizBelongsToAuthor do
  use Ecto.Migration

  def change do
    alter table(:quizzes) do
      add :author_id, references(:authors, on_delete: :delete_all, type: :binary_id)
    end
  end
end
