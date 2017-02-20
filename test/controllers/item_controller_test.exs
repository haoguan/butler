defmodule Butler.ItemControllerTest do
  use Butler.ConnCase
  use Timex

  test "POST api/v1/items?alexa_id=&item=" do
    mock_user = insert_mock_user("amzn1.test.setupuser.id")
    conn = post build_conn(), "api/v1/items/", [alexa_id: mock_user.alexa_id, item: "kitchen towels"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "type" => type, "modifier" => modifier,
      "expiration_date" => expiration_date, "expiration_string" => _}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert type == "towels"
    assert modifier == "kitchen"
    # TODO: Can't match expiration string b/c remaining days depends on month, e.g. Feb has fewer days!
    # assert String.contains?(expiration_string, "in 30 days")

    # negative if first datetime occurs before second
    assert Timex.diff(Timex.now(), expiration, :months) == -1
  end

  test "POST api/v1/items?alexa_id=&item= with no modifiers" do
    mock_user = insert_mock_user("amzn1.test.setupuser.id")
    conn = post build_conn(), "api/v1/items/", [alexa_id: mock_user.alexa_id, item: "bedsheets"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "type" => type, "modifier" => modifier,
      "expiration_date" => expiration_date, "expiration_string" => _}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert type == "bedsheets"
    # TODO: Should this be empty string or nil if modifier doesn't exist?
    assert modifier == ""

    # negative if first datetime occurs before second
    assert Timex.diff(Timex.now(), expiration, :months) == -1
  end

  test "POST api/v1/items?alexa_id=&item= with trailing words" do
    mock_user = insert_mock_user("amzn1.test.setupuser.id")
    conn = post build_conn(), "api/v1/items/", [alexa_id: mock_user.alexa_id, item: "Angelina's clarisonic for shower"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "type" => type, "modifier" => modifier,
      "expiration_date" => expiration_date, "expiration_string" => expiration_string}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert type == "clarisonic"
    assert modifier == "Angelina's"
    # TODO: Can't match full string b/c dates are dynamic!!
    assert String.contains?(expiration_string, "in 2 months")

    # negative if first datetime occurs before second
    assert Timex.diff(Timex.now(), expiration, :months) == -3
  end

  test "GET api/v1/items&alexa_id=&item=" do
    %{user: user1, items: user1_items} = setup_users([
      %{id: "amzn1.test.user1.id", items: ["sweet ketchup from safeway", "room blinds near window", "evaporated milk"]},
      %{id: "amzn1.test.user2.id", items: ["jack cheese from trader's joe", "rib leftovers"]}
    ])
    |> List.first

    conn = get build_conn(), "api/v1/items", [alexa_id: user1.alexa_id, item: "room blinds"]
    %{"description" => description, "status" => status,
      "data" => response} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    # Assert response data items contains expected items
    expectedItem = user1_items |> Enum.filter(fn item ->
      item.type == "blinds" && item.modifier == "room"
    end)
    assert is_items_match_response(expectedItem, response)
  end

end
