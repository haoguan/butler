defmodule Butler.UserControllerTest do
  use Butler.ConnCase

  setup do
    user = insert_mock_user("amzn1.test.user1.id")
    user2 = insert_mock_user("amzn1.test.user2.id")
    {:ok, users: %{user1: user, user2: user2}}
  end

  test "POST api/v1/users" do
    conn = post build_conn(), "api/v1/users", [alexa_id: "amzn1.test.postuser.id"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "alexa_id_hash" => _}} = json_response(conn, 201)
    assert status == 201
    assert description == "User successfully created"
  end

  test "GET api/v1/users/id", context do
    %{user1: mock_user} = context[:users]
    conn = get build_conn(), Enum.join(["api/v1/users/", mock_user.id]), nil
    %{"description" => description, "status" => status,
      "data" => %{"id" => get_id, "alexa_id_hash" => _}} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    assert mock_user.id == get_id
  end

  test "GET api/v1/users", context do
    %{user1: mock_user, user2: mock_user_2} = context[:users]
    conn = get build_conn(), "api/v1/users", nil
    %{"description" => description, "status" => status,
      "data" => [%{"id" => index_id_1}, %{"id" => index_id_2}]} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    # Assert response data user ids contains expected mock user ids
    assert Enum.member?([index_id_1, index_id_2], mock_user.id)
    assert Enum.member?([index_id_1, index_id_2], mock_user_2.id)
  end
end