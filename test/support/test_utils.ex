defmodule Butler.TestUtils do
  alias Butler.Repo
  alias Butler.User

  @default_user "amzn1.ask.account.AEV4NLDBR4AIEB55QJYBOCSNX3QRE533OHT72UK4OAX5G" <>
  "BJTEORIRMG3MFLF2PNQ4KXNA3OTLK6GOLE2G6D3XWUXDJQ3XNCKGL5MIYMXOTVVN5LOVVIRMFGMPZI" <>
  "OAXPBEZX2IYGL4DWGTGA5E3DWRNVBFGTIKUM5OR3H3ZGXBOD6K3TGQI7WNP3VPLE3OPTEZ5RSFUHN6" <>
  "IK7YJA"

  def insert_mock_user(alexa_id \\ @default_user) do
    User.registration_changeset(%{:alexa_id => alexa_id})
    |> Repo.insert!
  end
end
