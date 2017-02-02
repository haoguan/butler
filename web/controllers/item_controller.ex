defmodule Butler.API.V1.ItemController do
  use Butler.Web, :controller
  alias Butler.Item

  # GET /users/user_id/items
  def index(conn, %{"user_id" => user_id}) do
    scoped_items = Item.query_user_items(user_id)
    ResponseController.render_data(conn, scoped_items)
  end

  # GET /items (Debug)
  def index(conn, _params) do
    items = Repo.all(Item)
    ResponseController.render_data(conn, items)
  end

  # GET /users/user_id/items/id
  def show(conn, %{"user_id" => _, "id" => id}) do
    case user = Repo.get(Item, id) do
      nil ->
        ResponseController.not_found(conn,
          %{description: Enum.join(["Item: ", id]) <> " not found"})
      _ ->
        ResponseController.render_data(conn, user)
    end
  end

  # POST /users/user_id/items
  def create(conn, params = %{"user_id" => _, "raw_term" => _}) do
    changeset = Item.registration_changeset(params)
    case Repo.insert(changeset) do
      {:ok, item} ->
        ResponseController.render_created(conn, item, "Item successfully created")
      {:error, changeset} ->
        ResponseController.changeset_error(conn, changeset)
    end
  end

end
