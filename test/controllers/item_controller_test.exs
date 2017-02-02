defmodule Butler.ItemControllerTest do
  use Butler.ConnCase
  use Timex

  setup do
    user = insert_mock_user("amzn1.test.user1.id")
    {:ok, users: %{user1: user}}
  end

  test "POST api/v1/users/user_id/items", context do
    %{user1: mock_user} = context[:users]
    # {:ok, start_date} = Timex.now()
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

end
