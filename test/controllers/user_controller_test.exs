defmodule Butler.UserControllerTest do
  use Butler.ConnCase

  test "POST api/v1/users" do
    conn = post build_conn(), "api/v1/users", [alexa_id: "amzn1.test.postuser.id"]
    %{"description" => description, "status" => status,
      "data" => %{"id" => _, "alexa_id" => _}} = json_response(conn, 201)
    assert status == 201
    assert description == "User successfully created"
  end

  test "POST api/v1/users with exceeding length alexa_id" do

    large_alexa_id = "amzn1.ask.account.AEV4NLDBR4AIEB55QJYBOCSNX3QRE533OHT72UK4OAX5G" <>
    "BJTEORIRMG3MFLF2PNQ4KXNA3OTLK6GOLE2G6D3XWUXDJQ3XNCKGL5MIYMXOTVVN5LOVVIRMFGMPZI" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
    "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6"

    conn = post build_conn(), "api/v1/users", [alexa_id: large_alexa_id]
    assert %{"errors" => errors} = json_response(conn, 422)
    assert Enum.member?(errors, %{"detail" => "should be at most 255 character(s)",
      "field" => "alexa_id"})
  end

  test "POST api/v1/users with zero length alexa_id" do
    tiny_alexa_id = "h"

    conn = post build_conn(), "api/v1/users", [alexa_id: tiny_alexa_id]
    assert %{"errors" => errors} = json_response(conn, 422)
    assert Enum.member?(errors, %{"detail" => "should be at least 2 character(s)",
      "field" => "alexa_id"})
  end

  test "GET api/v1/users/id" do
    mock_user = insert_mock_user("amzn1.test.user1.id")
    conn = get build_conn(), Enum.join(["api/v1/users/", mock_user.id]), nil
    %{"description" => description, "status" => status,
      "data" => %{"id" => get_id, "alexa_id" => _}} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    assert mock_user.id == get_id
  end

  test "GET api/v1/users" do
    mock_user = insert_mock_user("amzn1.test.user1.id")
    mock_user_2 = insert_mock_user("amzn1.test.user2.id")
    conn = get build_conn(), "api/v1/users", nil
    %{"description" => description, "status" => status,
      "data" => data = [%{"id" => index_id_1}, %{"id" => index_id_2}]} = json_response(conn, 200)
    assert status == 200
    assert description == "Operation successfully completed"
    # Assert response data user ids contains expected mock user ids
    assert Enum.member?([index_id_1, index_id_2], mock_user.id)
    assert Enum.member?([index_id_1, index_id_2], mock_user_2.id)
    assert Enum.count(data) == 2
  end
end
