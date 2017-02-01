defmodule Butler.API.V1.UserController do
  use Butler.Web, :controller
  alias Butler.User

  def index(conn, _params) do
    users = Repo.all(User)
    ResponseController.render_data(conn, users)
  end

  def show(conn, %{"id" => id}) do
    case user = Repo.get(User, id) do
      nil ->
        ResponseController.not_found(conn,
          %{description: Enum.join(["User: ", id]) <> " not found"})
      _ ->
        ResponseController.render_data(conn, user)
    end
  end

  def create(conn, user_params) do
    changeset = User.registration_changeset(user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        ResponseController.render_created(conn, user, "User successfully created")
      {:error, changeset} ->
        ResponseController.changeset_error(conn, changeset)
    end
  end

end
