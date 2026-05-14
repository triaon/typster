defmodule TypsterWeb.E2EAuthController do
  use TypsterWeb, :controller

  alias Typster.Accounts
  alias Typster.Accounts.User
  alias Typster.Repo
  alias TypsterWeb.UserAuth

  def create(conn, params) do
    email =
      params
      |> Map.get("email", default_email())
      |> String.trim()
      |> String.downcase()

    user =
      case Accounts.get_user_by_email(email) do
        nil -> insert_confirmed_user!(email)
        existing -> ensure_confirmed!(existing)
      end

    UserAuth.log_in_user(conn, user)
  end

  defp insert_confirmed_user!(email) do
    now = DateTime.utc_now(:second)

    %User{}
    |> Ecto.Changeset.change(%{
      email: email,
      hashed_password: Bcrypt.hash_pwd_salt("e2e-unused"),
      confirmed_at: now
    })
    |> Repo.insert!()
  end

  defp ensure_confirmed!(%User{confirmed_at: nil} = user) do
    user
    |> Ecto.Changeset.change(confirmed_at: DateTime.utc_now(:second))
    |> Repo.update!()
  end

  defp ensure_confirmed!(user), do: user

  defp default_email do
    unique = System.unique_integer([:positive, :monotonic])
    "e2e-#{unique}@typster.test"
  end
end
