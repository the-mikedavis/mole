defmodule MoleWeb.Router do
  use MoleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MoleWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    resources("/users", UserController, only: [:show, :new, :create, :index])
  end
end
