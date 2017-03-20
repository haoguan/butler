defmodule Butler.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :item, :string, null: false
      add :type, :string
      add :expiration_date, :utc_datetime
      add :expiration_string, :string
      add :user_id, references(:users)

      timestamps
    end

    # items_type_item_user_id_index
    create unique_index(:items, [:type, :item, :user_id])
  end
end
