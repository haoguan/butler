defmodule TestItem do
  defstruct name: "", expiration_date: Timex.now, expiration_string: "test"
end

defmodule Butler.TestUtils do
  alias Butler.Repo
  alias Butler.User
  alias Butler.Item
  use Timex

  @default_user "amzn1.ask.account.AEV4NLDBR4AIEB55QJYBOCSNX3QRE533OHT72UK4OAX5G" <>
  "BJTEORIRMG3MFLF2PNQ4KXNA3OTLK6GOLE2G6D3XWUXDJQ3XNCKGL5MIYMXOTVVN5LOVVIRMFGMPZI" <>
  "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
  "IK7YJA"

  def insert_mock_user(alexa_id \\ @default_user) do
    User.registration_changeset(%{"alexa_id" => alexa_id})
    |> Repo.insert!
  end

  def insert_mock_item(alexa_id, item, expiration_date, expiration_string) do
    Item.test_registration_changeset(%{"alexa_id" => alexa_id, "item" => item},
      %{"expiration_date" => expiration_date, "expiration_string" => expiration_string})
    |> Repo.insert!
  end

  def setup_users(user_info) when is_list(user_info) do
    user_info
    |> Enum.map(fn %{id: alexa_id, items: test_items} ->
        user = insert_mock_user(alexa_id)
        # Ensure v is a list of items
        items = List.flatten([test_items])
        |> Enum.map(fn test_item ->
            insert_mock_item(alexa_id, test_item.name, test_item.expiration_date, test_item.expiration_string)
          end)

        %{user: user, items: items}
      end)
  end

  def convert_ISO_to_Timex(datetime) do
    case Timex.parse(datetime, "{ISO:Extended}") do
      {:ok, d} ->
        {:ok, Timex.to_datetime(d)}
      {:error, _} -> :error
    end
  end


  ###########
  # HELPERS #
  ###########

  def is_items_match_response(items, response) do
    # Convert response map into item structs
    response_structs = [response]
    |> List.flatten
    |> Enum.map(fn item_response ->
      struct(Item, string_to_atom_keys(item_response))
    end)

    # Compare key values in both item arrays using set
    Item.compare_item_arrays(items, response_structs)
  end

  defp string_to_atom_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
