defmodule Typster.Jobs.PeriodicSnapshot do
  use Oban.Worker, queue: :default, max_attempts: 3
  import Ecto.Query

  @impl Oban.Worker
  def perform(_job) do
    alias Typster.Projects.FileRevision
    alias Typster.Repo

    files = Typster.Repo.all(Typster.Projects.File)

    Enum.each(files, fn file ->
      revisions =
        from(r in FileRevision, where: r.file_id == ^file.id, order_by: [desc: r.sequence])
        |> Repo.all()

      case revisions do
        [latest_revision | _rest] ->
          if latest_revision.content != file.content do
            sequence = latest_revision.sequence + 1

            %FileRevision{file_id: file.id, inserted_at: DateTime.utc_now(:second)}
            |> FileRevision.changeset(%{
              content: file.content,
              sequence: sequence
            })
            |> Repo.insert()
          end

        [] ->
          :ok
      end
    end)

    :ok
  end
end
