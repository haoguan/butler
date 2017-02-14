defmodule Butler.User do
  alias Butler.User
  @derive {Poison.Encoder, only: [:id, :alexa_id]}

  use Butler.Web, :model

  schema "users" do
    field :alexa_id, :string
    has_many :items, Butler.Item

    timestamps
  end

  @allowed_fields ~w(alexa_id)
  @required_fields :alexa_id

  def registration_changeset(params) do
    %User{}
    |> cast(params, @allowed_fields)
    |> validate_alexa_id
    |> validate_required(@required_fields)
  end

  def validate_alexa_id(changeset) do
    changeset
    |> validate_length(:alexa_id, min: 2, max: 255)
  end

  ###########
  # QUERIES #
  ###########

  def query_matching_user(alexa_id) do
    from u in User,
    where: u.alexa_id == ^alexa_id,
    select: u,
    limit: 1
  end

end
