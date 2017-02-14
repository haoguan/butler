defmodule Butler.API.V1.ItemController do
  use Butler.Web, :controller
  alias Butler.Item

  # GET /items scoped to user
  def index(conn, %{"alexa_id" => alexa_id}) do
    scoped_items = Item.query_user_items(alexa_id)
    ResponseController.render_data(conn, Repo.all(scoped_items))
  end

  # GET /items (Debug)
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

  # GET /users/user_id/items/?raw_term

  # POST /items
  # NOTE: user_id is alexa id, still need to convert to db user id
  def create(conn, params = %{"alexa_id" => _, "item" => _}) do
    changeset = Item.registration_changeset(params)
    case Repo.insert(changeset) do
      {:ok, item} ->
        ResponseController.render_created(conn, item, "Item successfully created")
      {:error, changeset} ->
        ResponseController.changeset_error(conn, changeset)
    end
  end

end
