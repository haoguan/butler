defmodule Butler.StatusControllerTest do
  use Butler.ConnCase

  @start Timex.to_datetime({2017, 5, 26})
  @expirations %{
    :days => Timex.shift(@start, days: 5),
    :weeks => Timex.shift(@start, weeks: 2),
    :month => Timex.shift(@start, months: 1),
    :passed => Timex.shift(@start, days: -1)
  }

  setup do
    users = setup_users([
      %{id: "amzn1.test.user1.id", items: [%TestItem{name: "sweet ketchup from safeway", expiration_date: @expirations[:days]},
                                           %TestItem{name: "evaporated milk", expiration_date: @expirations[:weeks]},
                                           %TestItem{name: "room blinds near window", expiration_date: @expirations[:month]},
                                           %TestItem{name: "blue cheese", expiration_date: @expirations[:passed]}]},
      %{id: "amzn1.test.user2.id", items: [%TestItem{name: "jack cheese from trader's joe", expiration_date: @expirations[:weeks]},
                                           %TestItem{name: "rib leftovers", expiration_date: @expirations[:month]}]}
    ])
    {:ok, [users: users]}
  end

  test "GET api/v1/status?alexa_id=", context do
    %{user: user1, items: user1_items} = context[:users] |> List.first
    conn = get build_conn(), "api/v1/status", [alexa_id: user1.alexa_id, start_date: @start]

    %{"description" => description, "status" => status,
      "data" => response} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"

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
