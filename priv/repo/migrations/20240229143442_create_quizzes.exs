defmodule Quic.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table(:quizzes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :total_points, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
