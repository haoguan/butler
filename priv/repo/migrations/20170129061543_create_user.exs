defmodule Butler.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :alexa_id, :string, null: false

      timestamps
    end
  end
end
