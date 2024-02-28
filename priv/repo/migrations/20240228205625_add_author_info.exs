defmodule Quic.Repo.Migrations.AddAuthorInfo do
  use Ecto.Migration

  def change do
    alter table(:authors) do
      add :username, :citext, null: false
      add :display_name, :string, null: false
    end

    create unique_index(:authors, [:username])
  end
end
