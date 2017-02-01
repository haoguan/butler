defmodule Butler.User do
  alias Butler.User
  @derive {Poison.Encoder, only: [:id, :alexa_id_hash]}

  use Butler.Web, :model

  schema "users" do
    field :alexa_id, :string, virtual: true
    field :alexa_id_hash, :string
    has_many :items, Butler.Item

    timestamps
  end

  @allowed_fields ~w(alexa_id)
  @required_fields :alexa_id_hash

  def registration_changeset(params) do
    %User{}
    |> cast(params, @allowed_fields)
    |> validate_alexa_id
    |> encrypt_alexa_id
    |> validate_required(@required_fields)
  end

  def validate_alexa_id(changeset) do
    changeset
    |> validate_length(:alexa_id, min: 2, max: 255)
  end

  def encrypt_alexa_id(changeset) do
    case changeset do
      # Current changeset must be valid, and includes alexa_id as part of the changes
      %Ecto.Changeset{valid?: true, changes: %{alexa_id: alexa_id}} ->
        put_change(changeset, :alexa_id_hash, Comeonin.Bcrypt.hashpwsalt(alexa_id))
      # Else, no alexa_id in map, so don't waste time.
      _ ->
        changeset
    end
  end

end
