defmodule Butler.ResponseView do
  use Butler.Web, :view

  # UNAUTHORIZED
  def render("unauthenticated.json", _) do
    %{
      "status": 401,
      "description": "Invalid or missing authentication token"
    }
  end

  # UNAUTHORIZED
  def render("invalid_login.json", _) do
    %{
      "status": 401,
      "description": "Invalid username and password combination"
    }
  end

  # FORBIDDEN
  def render("unauthorized.json", _) do
    %{
      "status": 403,
      "description": "You do not have permission to view this page"
    }
  end

  # NOT FOUND WITH DESCRIPTION
  def render("not_found.json", %{description: description}) do
    %{
      "status": 404,
      "description": description
    }
  end

  # NOT FOUND
  def render("not_found.json", _) do
    %{
      "status": 404,
      "description": "Object not found"
    }
  end

  # UNPROCESSABLE ENTITY
  def render("changeset_error.json", %{changeset: changeset}) do
    %{
      "status": 422,
      "errors": map_changeset_error_to_json(changeset)
    }
  end

  # 201 RESPONSE WITH DESCRIPTION
  def render("data_created.json", %{data: data, description: description}) do
    %{
      "status": 201,
      "description": description,
      "data": data
    }
  end

  # 200 RESPONSE WITH DESCRIPTION
  def render("data.json", %{data: data, description: description}) do
    %{
      "status": 200,
      "description": description,
      "data": data
    }
  end

  # 200 RESPONSE
  def render("data.json", %{data: data}) do
    %{
      "status": 200,
      "description": "Operation successfully completed",
      "data": data
    }
  end

  # Map changeset errors to json
  # http://www.thisisnotajoke.com/blog/2015/09/serializing-ecto-changeset-errors-to-jsonapi-in-elixir.html
  def map_changeset_error_to_json(changeset) do
    Enum.map(changeset.errors, fn {field, detail} ->
      %{
        field: field,
        detail: render_detail(detail)
      }
    end)
  end

  def render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail(message) do
    message
  end
end
