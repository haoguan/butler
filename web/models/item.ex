defmodule Butler.Item do
  alias Butler.Item
  @derive {Poison.Encoder, only: [:id, :type, :modifier, :expiration_date]}

  use Butler.Web, :model
  alias Butler.Classify

  # TODO: Support items with generic modifiers
  # e.g. kitchen towel, Angelina's toothbrush
  schema "items" do
    field :raw_term, :string, virtual: true

    field :type, :string
    field :modifier, :string
    field :expiration_date, :utc_datetime
    belongs_to :user, Butler.User

    timestamps
  end

  @allowed_fields ~w(raw_term user_id)
  @required_fields ~w(modifier type expiration_date user_id)

  def registration_changeset(params) do
    %Item{}
    |> cast(params, @allowed_fields)
    |> addTermComponents(params)
    # TODO: Add expiration date to changeset
    |> addExpirationDate
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :items_type_modifier_user_id_index)
  end

  def addTermComponents(changeset, %{"raw_term" => raw_term}) do
    interpretation = Classify.interpret_term(raw_term)
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
  def addTermComponents(_, _) do
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
          expiration_date ->
            put_change(changeset, :expiration_date, expiration_date)
        end
    end
  end

end
