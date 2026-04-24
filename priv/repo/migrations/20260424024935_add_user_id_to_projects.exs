defmodule Typster.Repo.Migrations.AddUserIdToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
    end

    create index(:projects, [:user_id])
  end
end
