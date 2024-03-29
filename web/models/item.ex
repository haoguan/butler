defmodule Butler.Item do
  alias Butler.Item
  alias Butler.User
  @derive {Poison.Encoder, only: [:id, :user_id, :item, :expiration_date, :expiration_string]}

  use Butler.Web, :model
  alias Butler.DateInterpreter

  schema "items" do
    field :alexa_id, :string, virtual: true
    field :item, :string
    field :expiration, :string, virtual: true
    field :start_date, :utc_datetime, virtual: true
    field :expiration_date, :utc_datetime
    field :expiration_string, :string
    belongs_to :user, Butler.User

    timestamps()
  end

  @allowed_fields ~w(item expiration alexa_id start_date)
  @required_fields [:item, :expiration_date, :expiration_string, :user_id]

  def registration_changeset(params) do
    setup_changeset(params)
    |> interpretExpiration
    |> validate_changeset
  end

  # TODO: Consolidate this changeset by using the same relative date interpretation method
  def test_registration_changeset(params, %{"expiration_date" => expiration_date, "expiration_string" => expiration_string}) do
    setup_changeset(params)
    # TODO: Require expiration string for testing too
    |> putExpirationDate(expiration_date, expiration_string)
    |> validate_changeset
  end

  ########################
  # CHANGESET COMPONENTS #
  ########################

  def setup_changeset(params) do
    %Item{}
    |> cast(params, @allowed_fields)
    |> convertAlexaIdToUserId(params)
  end

  def validate_changeset(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :items_type_item_user_id_index)
  end

  ###########
  # HELPERS #
  ###########

  def convertAlexaIdToUserId(changeset, %{"alexa_id" => alexa_id}) do
    # Should only be one
    # TODO: Need to create user if user doesn't already exist!
    case Repo.one(User.query_matching_user(alexa_id)) do
      nil ->
        IO.puts "failed to find a user with alexa_id"
        changeset
      user ->
        IO.puts "successfully fetched alexa id"
        changeset
        |> put_change(:user_id, user.id)
        |> delete_change(:alexa_id)
    end

  end

  def interpretExpiration(changeset) do
    start_date =
      with start_date when not is_nil(start_date) <- get_change(changeset, :start_date) do
        start_date
      else
        nil
      end

    case get_change(changeset, :expiration) do
      nil ->
        IO.puts "interpretExpirationDate: expiration not found in changeset"
        changeset
      user_expiration ->
        IO.puts "expiration date exists in changeset"
        case DateInterpreter.interpret_expiration(user_expiration, start_date) do
          {:error, invalid_expiration} ->
            IO.puts "interpretExpirationDate: unable to interpret -  " <> invalid_expiration <> "."
            changeset
          {:ok, expiration_date, expiration_string} ->
            IO.puts "successfully interpreted expiration"
            putExpirationDate(changeset, expiration_date, expiration_string)
        end
    end
  end

  def putExpirationDate(changeset, expiration_date, expiration_string) do
    changeset
    |> put_change(:expiration_date, expiration_date)
    |> put_change(:expiration_string, expiration_string)
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

  def query_user_items_by_item_name(alexa_id, name) do
    user_items = query_user_items(alexa_id)
    from i in user_items,
    where: i.item == ^name
  end

  # PRIMARILY FOR TESTING
  def query_user_items_within_expiration_interval(alexa_id, start_date) do
    user_items = query_user_items(alexa_id)
    from i in user_items,
    where: fragment("? >= ? AND ? - ? <= interval '2 weeks'", i.expiration_date, ^start_date, i.expiration_date, ^start_date),
    order_by: i.expiration_date
  end

  def query_user_items_within_expiration_interval(alexa_id) do
    user_items = query_user_items(alexa_id)
    from i in user_items,
    where: fragment("? >= now() AND ? - now() <= interval '2 weeks'", i.expiration_date, i.expiration_date),
    order_by: i.expiration_date
  end

  # PRIMARILY FOR TESTING
  def query_expired_user_items(alexa_id, start_date) do
    user_items = query_user_items(alexa_id)
    from i in user_items,
    where: fragment("? - ? > interval '1 second'", ^start_date, i.expiration_date),
    order_by: i.expiration_date
  end

  def query_expired_user_items(alexa_id) do
    user_items = query_user_items(alexa_id)
    from i in user_items,
    where: fragment("now() - ? > interval '1 second'", i.expiration_date),
    order_by: i.expiration_date
  end

  ##############
  # CONVERSION #
  ##############

  def extract_key_fields(item) do
    %{id: item.id, item: item.item}
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
