defmodule Quic.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :status, :string
      add :type, :string
      add :current_question, :integer
      add :quiz, :map
      add :immediate_feedback, :boolean
      add :final_feedback, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
