defmodule Quic.Repo.Migrations.AddTeamsAuthorsRelationship do
  use Ecto.Migration

  def change do
    create table(:teams_authors) do
      add :team_id, references(:teams, on_delete: :delete_all, type: :binary_id)
      add :author_id, references(:authors, on_delete: :delete_all, type: :binary_id)
    end

    create unique_index(:teams_authors, [:team_id, :author_id])
  end
end