defmodule TypsterWeb.Api.HealthController do
  use TypsterWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok", app: "typster"})
  end
end
