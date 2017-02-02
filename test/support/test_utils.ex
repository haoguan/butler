defmodule Butler.TestUtils do
  alias Butler.Repo
  alias Butler.User
  alias Butler.Item

  @default_user "amzn1.ask.account.AEV4NLDBR4AIEB55QJYBOCSNX3QRE533OHT72UK4OAX5G" <>
  "BJTEORIRMG3MFLF2PNQ4KXNA3OTLK6GOLE2G6D3XWUXDJQ3XNCKGL5MIYMXOTVVN5LOVVIRMFGMPZI" <>
  "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
  "IK7YJA"

  def insert_mock_user(alexa_id \\ @default_user) do
    User.registration_changeset(%{"alexa_id" => alexa_id})
    |> Repo.insert!
  end

  def insert_mock_item(user_id, raw_term) do
    Item.registration_changeset(%{"user_id" => user_id, "raw_term" => raw_term})
    |> Repo.insert!
  end

  def setup_users_with_items do
    # User with one item
    user = insert_mock_user("amzn1.test.user1.id")
    item1 = insert_mock_item(user.id, "sweet ketchup from safeway")

    # User with a few items
    user2 = insert_mock_user("amzn1.test.user2.id")
    # TODO: Add test for capital letters!
    item2 = insert_mock_item(user2.id, "jack cheese from trader's joe")
    item3 = insert_mock_item(user2.id, "rib leftovers")
    {:ok, users: %{user1: user, user2: user2}, items: %{item1: item1, item2: item2, item3: item3}}
  end

  def convert_ISO_to_Timex(datetime) do
    case Timex.parse(datetime, "{ISO:Extended}") do
      {:ok, d} ->
        {:ok, Timex.to_datetime(d)}
      {:error, _} -> :error
    end
  end
end
