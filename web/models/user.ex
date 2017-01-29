defmodule Butler.User do
  @derive {Poison.Encoder, only: [:id, :alexa_id_hash]}

  use Butler.Web, :model

  schema "users" do
    field :alexa_id, :string, virtual: true
    field :alexa_id_hash, :string

    timestamps
  end

  @required_fields ~w(alexa_id)
  @optional_fields ~w()

  def registration_changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_alexa_id
    |> encrypt_alexa_id
  end

  def validate_alexa_id(changeset) do
    changeset
    |> validate_length(:alexa_id, min: 1, max: 255)
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
