defmodule MoleWeb.Router do
  @moduledoc false
  use MoleWeb, :router

  alias MoleWeb.Plugs

  @user_socket_secret Application.get_env(:mole, :user_socket_secret)

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Plugs.Auth)
    plug(Plugs.Admin)
    plug(Plugs.Survey)
    plug(Plugs.Condition)
    plug(Plugs.Consent)
    plug(Plugs.Learning)
    plug(Plugs.Feedback)
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
    # custom because :delete requires an id, so it can't be used in a form
    post("/admins/delete", AdminController, :delete)
    get("/join/:slug", SurveyController, :join)
    resources("/surveys", SurveyController)
    get("/download/:id", SurveyController, :download)
    get("/consent", ConsentController, :index)
    post("/consent", ConsentController, :agree)
    resources("/learn", LearningController, only: [:index, :show])
    resources("/images", ImageController, only: [:index, :show])
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
