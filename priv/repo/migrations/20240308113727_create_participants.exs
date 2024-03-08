defmodule Quic.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :total_points, :integer
      add :current_question, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
