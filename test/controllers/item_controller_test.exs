defmodule Butler.ItemControllerTest do
  use Butler.ConnCase
  use Timex

  ##########
  # CREATE #
  ##########

  test "POST api/v1/items?alexa_id=&item=&expiration= with exact date" do
    mock_user = insert_mock_user()
    registered_item = "bedsheets"
    conn = post build_conn(), "api/v1/items/", [alexa_id: mock_user.alexa_id, item: registered_item, expiration: "on June 24th, 2025"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "item" => item,
      "expiration_date" => expiration_date, "expiration_string" => _}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert item == registered_item
    assert expiration == Timex.to_datetime({2025, 6, 24})
  end

  test "POST api/v1/items?alexa_id=&item=&expiration= with relative date" do
    mock_user = insert_mock_user()
    registered_item = "ketchup"
    start_date = Timex.to_datetime({2017, 5, 26})
    conn = post build_conn(), "api/v1/items/", [alexa_id: mock_user.alexa_id, item: registered_item,
      expiration: "in 3 weeks", start_date: start_date]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "item" => item,
      "expiration_date" => expiration_date, "expiration_string" => _}} = json_response(conn, 201)

    {:ok, expiration} = convert_ISO_to_Timex(expiration_date)
    assert status == 201
    assert description == "Item successfully created"
    assert item == registered_item
    assert expiration == Timex.to_datetime({2017, 6, 16})
  end

  ##########
  # STATUS #
  ##########

  test "GET api/v1/items?alexa_id=&status=" do
    start_date = Timex.to_datetime({2017, 5, 26})
    five_days_expiration = Timex.to_datetime({2017, 5, 31})
    two_weeks_expiration = Timex.to_datetime({2017, 6, 9})
    one_month_expiration = Timex.to_datetime({2017, 6, 26})
    passed_expiration = Timex.to_datetime({2017, 5, 25})
    %{user: user1, items: user1_items} = setup_users([
      %{id: "amzn1.test.user1.id", items: [%TestItem{name: "sweet ketchup from safeway", expiration_date: two_weeks_expiration},
                                           %TestItem{name: "room blinds near window", expiration_date: one_month_expiration},
                                           %TestItem{name: "evaporated milk", expiration_date: five_days_expiration},
                                           %TestItem{name: "blue cheese", expiration_date: passed_expiration}]},
      %{id: "amzn1.test.user2.id", items: [%TestItem{name: "jack cheese from trader's joe", expiration_date: two_weeks_expiration},
                                           %TestItem{name: "rib leftovers", expiration_date: one_month_expiration}]}
    ])
    |> List.first

    conn = get build_conn(), "api/v1/items", [alexa_id: user1.alexa_id, status: 1, start_date: start_date]

    %{"description" => description, "status" => status,
      "data" => response} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    # Assert response data items contains expected warning and expired items
    expired_items = user1_items |> Enum.filter(fn item ->
      item.item == "blue cheese"
    end)
    warning_items = user1_items |> Enum.filter(fn item ->
      item.item == "sweet ketchup from safeway" || item.item== "evaporated milk"
    end)

    assert is_items_match_response_for_key(expired_items, response, "expired_items")
    assert is_items_match_response_for_key(warning_items, response, "warning_items")

  end

  #######
  # GET #
  #######

  test "GET api/v1/items&alexa_id=&item=" do
    %{user: user1, items: user1_items} = setup_users([
      %{id: "amzn1.test.user1.id", items: [%TestItem{name: "sweet ketchup from safeway"}, %TestItem{name: "room blinds"}, %TestItem{name: "evaporated milk"}]},
      %{id: "amzn1.test.user2.id", items: [%TestItem{name: "jack cheese from trader's joe"}, %TestItem{name: "rib leftovers"}]}
    ])
    |> List.first

    conn = get build_conn(), "api/v1/items", [alexa_id: user1.alexa_id, item: "room blinds"]
    %{"description" => description, "status" => status,
      "data" => response} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    # Assert response data items contains expected items
    expected_item = user1_items |> Enum.filter(fn item ->
      item.item == "room blinds"
    end)
    assert is_items_match_response(expected_item, response)

    unexpected_item = user1_items |> Enum.filter(fn item ->
      item.item == "rib leftovers"
    end)
    assert Enum.empty?(unexpected_item)
  end

  test "GET api/v1/items&alexa_id=&item= for item that doesn't exist" do
    %{user: user1, items: user1_items} = setup_users([
      %{id: "amzn1.test.user1.id", items: [%TestItem{name: "sweet ketchup from safeway"}, %TestItem{name: "room blinds"}, %TestItem{name: "evaporated milk"}]},
      %{id: "amzn1.test.user2.id", items: [%TestItem{name: "jack cheese from trader's joe"}, %TestItem{name: "rib leftovers"}]}
    ])
    |> List.first

    query_item = "nonexistent sauce"
    conn = get build_conn(), "api/v1/items", [alexa_id: user1.alexa_id, item: query_item]
    %{"description" => description, "status" => status} = json_response(conn, 404)
    assert status == 404
    assert description ==  query_item <> ": is not found"
  end
end
