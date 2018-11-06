defmodule MoleWeb.LearningController do
  use MoleWeb, :controller

  alias Mole.Content.Condition
  alias MoleWeb.Router.Helpers, as: Routes
  alias MoleWeb.Plugs.Learning

  plug(:learn)

  # showing how to play
  def index(conn, _params) do
    image =
      case Condition.to_tuple(conn.assigns.condition) do
        {:none, _} -> "/images/instruction_control.png"
        _ -> "/images/instruction_condition.png"
      end

    conn
    |> assign(:image, image)
    |> render("show.html", next: Routes.game_path(conn, :index))
  end

  # showing a condition
  def show(conn, %{"id" => id}) do
    with n when is_integer(n) <- conn.assigns.condition,
         image when not is_nil(image) <- Condition.image_for(n, id) do
      conn
      |> assign(:image, image)
      |> next(id)
      |> render("show.html")
    else
      nil -> redirect(conn, to: Routes.learning_path(conn, :index))
    end
  end

  defp learn(conn, _opts), do: Learning.learn(conn)

  defp next(conn, id) do
    id = String.to_integer(id)

    link =
      case Condition.image_for(conn.assigns.condition, id + 1) do
        nil -> Routes.game_path(conn, :index)
        _image -> Routes.learning_path(conn, :show, id + 1)
      end

    assign(conn, :next, link)
  end
end
