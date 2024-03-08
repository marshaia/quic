defmodule Quic.Repo.Migrations.SessionHasParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :session_id, references(:sessions, on_delete: :delete_all, type: :binary_id)
    end
  end
end
