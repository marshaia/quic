defmodule Quic.Repo.Migrations.CreateParameters do
  use Ecto.Migration

  def change do
    create table(:parameters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :text
      add :test_file, :text
      add :language, :string
      add :correct_answers, :map
      add :tests, {:array, :map}
      add :question_id, references(:questions, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
