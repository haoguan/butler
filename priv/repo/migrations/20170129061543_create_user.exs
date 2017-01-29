defmodule Butler.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :alexa_id_hash, :string

      timestamps
    end
  end
end
