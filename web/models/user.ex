defmodule Butler.User do
  @derive {Poison.Encoder, only: [:id, :alexa_id]}

  use Butler.Web, :model

  schema "users" do
    field :alexa_id, :string

    timestamps
  end

  @required_fields ~w(alexa_id)
  @optional_fields ~w()


  def registration_changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_alexa_id
  end

  def validate_alexa_id(model) do
    model
    |> unique_constraint(:alexa_id)
    |> validate_length(:alexa_id, min: 1, max: 255)
  end

end
