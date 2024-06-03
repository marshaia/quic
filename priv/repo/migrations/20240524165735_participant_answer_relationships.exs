defmodule Quic.Repo.Migrations.ParticipantAnswerRelationships do
  use Ecto.Migration

  def change do
    alter table(:participant_answers) do
      add :participant_id, references(:participants, on_delete: :delete_all, type: :binary_id)
    end
  end
end
