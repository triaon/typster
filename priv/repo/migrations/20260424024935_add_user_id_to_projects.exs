defmodule Typster.Repo.Migrations.AddUserIdToProjects do
  use Ecto.Migration

  @legacy_email "legacy-project-owner@typster.local"

  def up do
    alter table(:projects) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
    end

    flush()

    if legacy_projects_exist?() do
      ensure_legacy_user!()

      execute(
        """
        UPDATE projects
        SET user_id = (SELECT id FROM users WHERE email = '#{@legacy_email}')
        WHERE user_id IS NULL
        """,
        ""
      )
    end

    execute("ALTER TABLE projects ALTER COLUMN user_id SET NOT NULL", "")

    create index(:projects, [:user_id])
  end

  def down do
    drop index(:projects, [:user_id])

    alter table(:projects) do
      remove :user_id
    end
  end

  defp legacy_projects_exist? do
    %{rows: [[count]]} = repo().query!("SELECT COUNT(*) FROM projects", [])
    count > 0
  end

  defp ensure_legacy_user! do
    repo().query!(
      """
      INSERT INTO users (id, email, inserted_at, updated_at)
      VALUES ($1, $2, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC')
      ON CONFLICT (email) DO NOTHING
      """,
      [Ecto.UUID.generate() |> Ecto.UUID.dump!(), @legacy_email]
    )
  end
end
