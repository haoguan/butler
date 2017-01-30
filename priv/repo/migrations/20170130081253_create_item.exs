defmodule Butler.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :type, :string, null: false
      add :modifier, :string
      add :expiration_date, :utc_datetime
      add :user_id, references(:users)

      timestamps
    end

    # items_type_modifier_user_id_index
    create unique_index(:items, [:type, :modifier, :user_id])
  end
end
