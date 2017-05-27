defmodule Butler.API.V1.ItemController do
  use Butler.Web, :controller
  alias Butler.Item
  alias Butler.Classify

  # GET /items with term
  def index(conn, %{"alexa_id" => alexa_id, "item" => item}) do
    query = Item.query_user_items_by_item_name(alexa_id, item)
    ResponseController.render_data(conn, Repo.all(query))
  end

  def index(conn, %{"alexa_id" => alexa_id, "status" => _, "start_date" => start_date} = params) do
    warning_items = Item.query_user_items_within_expiration_interval(alexa_id, start_date) |> Repo.all
    expired_items = Item.query_expired_user_items(alexa_id, start_date) |> Repo.all
    ResponseController.render_data(conn, %{"warning_items" => warning_items, "expired_items" => expired_items})
  end

  # TODO: MAYBE CREATE SEPARATE STATUS CONTROLLER?
  # GET /items in bulk that need attention soon
  def index(conn, %{"alexa_id" => alexa_id, "status" => _} = params) do
    warning_items = Item.query_user_items_within_expiration_interval(alexa_id) |> Repo.all
    expired_items = Item.query_expired_user_items(alexa_id) |> Repo.all
    ResponseController.render_data(conn, %{"warning_items" => warning_items, "expired_items" => expired_items})
  end

  # GET /items scoped to user
  def index(conn, %{"alexa_id" => alexa_id}) do
    scoped_items = Item.query_user_items(alexa_id)
    ResponseController.render_data(conn, Repo.all(scoped_items))
  end

  # GET all /items (Debug)
  def index(conn, _params) do
    items = Repo.all(Item)
    ResponseController.render_data(conn, items)
  end

  # GET /items/id (Debug)
  def show(conn, %{"id" => id}) do
    case Repo.get(Item, id) do
      nil ->
        ResponseController.not_found(conn,
          %{description: Enum.join(["Item: ", id]) <> " not found"})
      user ->
        ResponseController.render_data(conn, user)
    end
  end

  # POST /items - item and also relative date
  def create(conn, params = %{"alexa_id" => _, "item" => _, "expiration" => _}) do
    changeset = Item.registration_changeset(params)
    case Repo.insert(changeset) do
      {:ok, item} ->
        ResponseController.render_created(conn, item, "Item successfully created")
      {:error, changeset} ->
        ResponseController.changeset_error(conn, changeset)
    end
  end

end
