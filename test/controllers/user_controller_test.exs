defmodule Butler.UserControllerTest do
  use Butler.ConnCase

  setup do
    user = insert_mock_user()
    {:ok, user: user}
  end

  test "POST api/v1/users" do
    conn = post build_conn(), "api/v1/users", [alexa_id: "amzn1.test.id"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "alexa_id_hash" => _}} = json_response(conn, 201)
    assert status == 201
    assert description == "User successfully created"
  end

  test "GET api/v1/users/id", context do
    mock_user = context[:user]
    # Assert created user and queried user has the same ID
    conn = get build_conn(), Enum.join(["api/v1/users/", mock_user.id]), nil
    %{"description" => description, "status" => status,
      "data" => %{"id" => get_id, "alexa_id_hash" => _}} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    assert mock_user.id == get_id
  end
end
