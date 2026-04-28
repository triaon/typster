defmodule TypsterWeb.Api.SessionController do
  use TypsterWeb, :controller

  alias Typster.Accounts

  def create(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.generate_user_session_token(user)
      json(conn, %{token: Base.url_encode64(token, padding: false)})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "invalid_credentials"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "missing_credentials"})
  end

  def delete(conn, _params) do
    with ["Bearer " <> encoded_token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Base.url_decode64(encoded_token, padding: false) do
      Accounts.delete_user_session_token(token)
    end

    send_resp(conn, :no_content, "")
  end
end
