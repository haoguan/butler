defmodule Butler.StatusControllerTest do
  use Butler.ConnCase

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

    conn = get build_conn(), "api/v1/status", [alexa_id: user1.alexa_id, start_date: start_date]

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
end
