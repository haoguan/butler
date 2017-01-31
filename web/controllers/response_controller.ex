defmodule Butler.ResponseController do
  use Phoenix.Controller
  alias Butler.ResponseView

  # 401 is related to bad authentication!
  def unauthenticated(conn) do
    conn
    |> halt()
    |> put_status(:unauthorized)
    |> render(ResponseView, "unauthenticated.json")
  end

  def invalid_login(conn) do
    conn
    |> halt()
    |> put_status(:unauthorized)
    |> render(ResponseView, "invalid_login.json")
  end

  # 403 is FORBIDDEN meaning you are authenticated, but NOT authorized.
  def unauthorized(conn) do
    conn
    |> halt()
    |> put_status(:forbidden)
    |> render(ResponseView, "unauthorized.json")
  end

  # 404 NOT FOUND
  def not_found(conn, description) do
    conn
    |> halt()
    |> put_status(:not_found)
    |> render(ResponseView, "not_found.json", description: description)
  end

  def not_found(conn) do
    conn
    |> halt()
    |> put_status(:not_found)
    |> render(ResponseView, "not_found.json")
  end

  # 422 WITH ERROR(S)
  def changeset_error(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ResponseView, "changeset_error.json", changeset: changeset)
  end

  # 201 WITH DESCRIPTION
  def render_created(conn, data, description) do
    conn
    |> put_status(:created)
    |> render(ResponseView, "data_created.json", data: data, description: description)
  end

  # 200 WITH DESCRIPTION
  def render_data(conn, data, description) do
    conn
    |> put_status(:ok)
    |> render(ResponseView, "data.json", data: data, description: description)
  end

  def render_data(conn, data) do
    conn
    |> put_status(:ok)
    |> render(ResponseView, "data.json", data: data)
  end
end
