defmodule MoleWeb.UserView do
  use MoleWeb, :view

  # on the first page, there is only one page
  def pagination(conn, %{last: 1, current: 1}), do: pages(conn, [1])

  # on the first page
  def pagination(conn, %{current: 1}), do: pages(conn, [1, 2])

  # on the last page
  def pagination(conn, %{last: p, current: p}), do: pages(conn, [p - 1, p])

  # somewhere in the middle
  def pagination(conn, %{current: current}),
    do: pages(conn, [current - 1, current, current + 1])

  defp pages(conn, pages) when is_list(pages), do: raw(_pages(conn, pages))

  defp _pages(conn, [page]), do: page(conn, page)
  defp _pages(conn, [a, b]),
    do: page(conn, a) <> ", " <> page(conn, b)
  defp _pages(conn, pages) when length(pages) == 3,
    do: Enum.map(pages, &page(conn, &1)) |> Enum.join(" ... ")

  # create an html link to a page
  defp page(conn, page) do
    {:safe, text} =
      link(page, to: Routes.user_path(conn, :index, %{page: page}))

    to_string(text)
  end
end
