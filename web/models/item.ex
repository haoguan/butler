defmodule Butler.Item do
  alias Butler.Item
  @derive {Poison.Encoder, only: [:id, :type, :modifier, :expiration_date]}

  use Butler.Web, :model
  alias Butler.Classify

  # TODO: Support items with generic modifiers
  # e.g. kitchen towel, Angelina's toothbrush
  schema "items" do
    field :raw_term, :string, virtual: true

    field :modifier, :string
    field :type, :string
    field :expiration_date, :utc_datetime
    belongs_to :user, Butler.User

    timestamps
  end

  @allowed_fields ~w(raw_term user_id)
  @required_fields ~w(modifier type expiration_date user_id)

  def registration_changeset(params) do
    %Item{}
    |> cast(params, @allowed_fields)
    |> parse_raw_input(params)
    |> validate_required(@required_fields)
  end

  def parse_raw_input(changeset, %{"raw_term" => raw_term}) do
    interpretation = Classify.interpret_term(raw_term)
    case interpretation do
      %{:type => type, :modifier => modifier} ->
        put_change(changeset, :type, type)
        put_change(changeset, :modifier, modifier)
        changeset
      _ ->
        IO.puts "interpretation of term failed"
    end
  end

  def parse_raw_input(_, _) do
    IO.puts "raw_term not found in params"
  end

end
