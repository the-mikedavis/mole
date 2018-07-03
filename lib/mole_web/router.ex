defmodule MoleWeb.Router do
  @moduledoc false
  use MoleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(MoleWeb.Auth)
    plug(:put_user_token)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MoleWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/play", GameController, :index)
    resources("/users", UserController, only: [:show, :new, :create, :index])
    resources("/sessions", SessionController, only: [:new, :create, :delete])
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)

      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
