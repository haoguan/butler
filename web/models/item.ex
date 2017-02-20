defmodule Butler.Item do
  alias Butler.Item
  alias Butler.User
  @derive {Poison.Encoder, only: [:id, :type, :modifier, :expiration_date, :expiration_string]}

  use Butler.Web, :model
  alias Butler.Classify

  # TODO: Support items with generic modifiers
  # e.g. kitchen towel, Angelina's toothbrush
  schema "items" do
    field :alexa_id, :string, virtual: true
    field :item, :string, virtual: true

    field :type, :string
    field :modifier, :string
    field :expiration_date, :utc_datetime
    field :expiration_string, :string
    belongs_to :user, Butler.User

    timestamps
  end

  @allowed_fields ~w(item alexa_id)
  @required_fields [:type, :expiration_date, :expiration_string, :user_id]

  def registration_changeset(params) do
    %Item{}
    |> cast(params, @allowed_fields)
    |> convertAlexaIdToUserId(params)
    |> addTermComponents(params)
    |> addExpirationDate
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :items_type_modifier_user_id_index)
  end

  ###########
  # HELPERS #
  ###########

  def convertAlexaIdToUserId(changeset, %{"alexa_id" => alexa_id}) do
    # Should only be one
    case Repo.one(User.query_matching_user(alexa_id)) do
      nil ->
        IO.puts "failed to find a user with alexa_id"
        changeset
      user ->
        changeset
        |> put_change(:user_id, user.id)
        |> delete_change(:alexa_id)
    end

  end

  def addTermComponents(changeset, %{"item" => item}) do
    interpretation = Classify.interpret_term(item)
    case interpretation do
      %{:type => type, :modifier => modifier} ->
        changeset
        |> put_change(:type, type)
        |> put_change(:modifier, modifier)
      _ ->
        IO.puts "interpretation of term failed"
        changeset
    end
  end

  # Error case
  def addTermComponents(_changeset, _params) do
    IO.puts "addTermComponents: raw_term not found in params"
  end

  def addExpirationDate(changeset) do
    case get_change(changeset, :type) do
      nil ->
        IO.puts "addExpirationDate: type cannot be found within changeset"
        changeset
      type ->
        case Classify.expirationDateForItem(type) do
          {:error, term} ->
            IO.puts "failure to find expirationDate for " <> term <> "."
            changeset
          {:ok, expiration_date, expiration_string} ->
            changeset
            |> put_change(:expiration_date, expiration_date)
            |> put_change(:expiration_string, expiration_string)
        end
    end
  end

  ###########
  # QUERIES #
  ###########

  # Items scoped to alexa_id
  def query_user_items(alexa_id) do
    from i in Item,
    join: u in User, on: i.user_id == u.id,
    where: u.alexa_id == ^alexa_id,
    select: i
  end

  def query_user_items_by_type(alexa_id, type, modifier) do
    user_items = query_user_items(alexa_id)
    from i in user_items,
    where: i.type == ^type and i.modifier == ^modifier
  end

  ##############
  # CONVERSION #
  ##############

  def extract_key_fields(item) do
    %{id: item.id, type: item.type, modifier: item.modifier}
  end

  def compare_item_arrays(items1, items2) do
    set1 = items1 |> Enum.map(fn item ->
      extract_key_fields(item)
    end)
    |> MapSet.new

    # Compare against first set
    items2 |> Enum.map(fn item ->
      extract_key_fields(item)
    end)
    |> MapSet.new
    |> MapSet.equal?(set1)
  end

end
