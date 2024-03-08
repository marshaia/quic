defmodule Quic.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :start_date, :date
      add :end_date, :date
      add :status, :string
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
