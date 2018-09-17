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
    case conn.assigns.condition do
      nil ->
        redirect(conn, to: Routes.learning_path(conn, :index))

      _ ->
        conn
        |> assign(:image, Condition.image_for(conn.assigns.condition, id))
        |> next(id)
        |> render("show.html")
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
