defmodule Typster.Repo do
  @moduledoc "Ecto repository for Typster's database access"
  use Ecto.Repo,
    otp_app: :typster,
    adapter: Ecto.Adapters.Postgres
end
