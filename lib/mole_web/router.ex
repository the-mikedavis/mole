defmodule MoleWeb.Router do
  @moduledoc false
  use MoleWeb, :router

  @user_socket_secret Application.get_env(:mole, :user_socket_secret)

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

  scope "/api", MoleWeb do
    pipe_through(:api)

    get("/taken", UserController, :taken)
  end

  scope "/", MoleWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/play", GameController, :index)
    get("/recap", GameController, :show)
    resources("/users", UserController, only: [:show, :new, :create, :index])
    resources("/sessions", SessionController, only: [:new, :create, :delete])
    resources("/admins", AdminController, only: [:index, :create])
    post("/admins/delete", AdminController, :delete)
    resources("/surveys", SurveyController)
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token =
        Phoenix.Token.sign(conn, @user_socket_secret, current_user.username)

      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
