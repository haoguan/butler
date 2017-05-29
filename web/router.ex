defmodule Butler.Router do
  use Butler.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", Butler.API.V1 do
    pipe_through :api

    resources "/users", UserController, only: [:index, :show, :create]
    resources "/items", ItemController, only: [:index, :show, :create]
    resources "/status", StatusController, only: [:index]
  end
end
