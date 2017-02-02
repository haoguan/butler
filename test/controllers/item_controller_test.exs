defmodule Butler.ItemControllerTest do
  use Butler.ConnCase
  use Timex

  setup do
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

  test "POST api/v1/users/user_id/items", context do
    %{user1: mock_user} = context[:users]
    conn = post build_conn(), Enum.join(["api/v1/users/", mock_user.id]) <> "/items", [raw_term: "kitchen towels"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "type" => type, "modifier" => modifier,
      "expiration_date" => expiration_date}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert type == "towels"
    assert modifier == "kitchen"

    # negative if first datetime occurs before second
    assert Timex.diff(Timex.now(), expiration, :months) == -1
  end

  test "POST api/v1/users/user_id/items with trailing words", context do
    %{user1: mock_user} = context[:users]
    conn = post build_conn(), Enum.join(["api/v1/users/", mock_user.id]) <> "/items", [raw_term: "Angelina's clarisonic for shower"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "type" => type, "modifier" => modifier,
      "expiration_date" => expiration_date}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert type == "clarisonic"
    assert modifier == "Angelina's"

    # negative if first datetime occurs before second
    assert Timex.diff(Timex.now(), expiration, :months) == -3
  end

  test "GET api/v1/users/user_id/items", context do
    %{user1: _, user2: experienced_user} = context[:users]
    %{item1: _, item2: experienced_item_1, item3: experienced_item_2} = context[:items]

    conn = get build_conn(), Enum.join(["api/v1/users/", experienced_user.id]) <> "/items", nil
    %{"description" => description, "status" => status,
      "data" => data = [%{"id" => item_id_1}, %{"id" => item_id_2}]} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    # Assert response data items contains expected items
    assert Enum.member?([item_id_1, item_id_2], experienced_item_1.id)
    assert Enum.member?([item_id_1, item_id_2], experienced_item_2.id)
    assert Enum.count(data) == 2
  end

end
