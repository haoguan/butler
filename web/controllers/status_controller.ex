defmodule Butler.API.V1.StatusController do
  use Butler.Web, :controller
  alias Butler.Item

  def index(conn, %{"alexa_id" => alexa_id, "start_date" => start_date} = params) do
    warning_items = Item.query_user_items_within_expiration_interval(alexa_id, start_date) |> Repo.all
    expired_items = Item.query_expired_user_items(alexa_id, start_date) |> Repo.all
    ResponseController.render_data(conn, %{"warning_items" => warning_items, "expired_items" => expired_items})
  end

  def index(conn, %{"alexa_id" => alexa_id}) do
    warning_items = Item.query_user_items_within_expiration_interval(alexa_id) |> Repo.all
    expired_items = Item.query_expired_user_items(alexa_id) |> Repo.all
    ResponseController.render_data(conn, %{"warning_items" => warning_items, "expired_items" => expired_items})
  end
end
