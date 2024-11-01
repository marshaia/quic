defmodule Quic.Repo.Migrations.CreateParticipantAnswers do
  use Ecto.Migration

  def change do
    create table(:participant_answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :answer, {:array, :text}, default: []
      add :result, :string
      add :points_obtained, :integer
      add :error_reason, :string
      add :question_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
