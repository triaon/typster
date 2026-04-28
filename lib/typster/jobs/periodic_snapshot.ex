defmodule Typster.Jobs.PeriodicSnapshot do
  @moduledoc "Oban job that snapshots file contents into file revisions"
  use Oban.Worker, queue: :default, max_attempts: 3
  import Ecto.Query
  alias Typster.Projects.FileRevision
  alias Typster.Repo

  @impl Oban.Worker
  def perform(_job) do
    files = Typster.Repo.all(Typster.Projects.File)

    Enum.each(files, fn file ->
      latest_revision =
        from(r in FileRevision,
          where: r.file_id == ^file.id,
          order_by: [desc: r.sequence],
          limit: 1
        )
        |> Repo.one()

      maybe_insert_revision(file, latest_revision)
    end)

    :ok
  end

  defp maybe_insert_revision(_file, nil), do: :ok

  defp maybe_insert_revision(file, latest_revision) do
    if latest_revision.content != file.content do
      sequence = latest_revision.sequence + 1

      %FileRevision{file_id: file.id, inserted_at: DateTime.utc_now(:second)}
      |> FileRevision.changeset(%{
        content: file.content,
        sequence: sequence
      })
      |> Repo.insert()
    end
  end
end
