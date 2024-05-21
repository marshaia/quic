defmodule Quic.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      #add :title, :string
      add :description, :text
      add :position, :integer
      add :points, :integer
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
