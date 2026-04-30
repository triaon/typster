defmodule TypsterWeb.PageController do
  use TypsterWeb, :controller

  def home(conn, _params) do
    conn
    |> put_root_layout(html: {TypsterWeb.Layouts, :marketing})
    |> render(:home)
  end
end
