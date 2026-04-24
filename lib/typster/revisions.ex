defmodule Typster.Revisions do
  @moduledoc """
  The Revisions context.
  """

  import Ecto.Query, warn: false
  alias Typster.Accounts.Scope
  alias Typster.Repo
  alias Typster.Projects.FileRevision

  def get_revision!(%Scope{user: user}, id) do
    from(r in FileRevision,
      join: f in assoc(r, :file),
      join: p in assoc(f, :project),
      where: r.id == ^id and p.user_id == ^user.id
    )
    |> Repo.one!()
  end

  def get_revision(%Scope{user: user}, id) do
    from(r in FileRevision,
      join: f in assoc(r, :file),
      join: p in assoc(f, :project),
      where: r.id == ^id and p.user_id == ^user.id
    )
    |> Repo.one()
  end

  def create_revision(%Scope{} = scope, file_id, content) do
    _file = Typster.Files.get_file!(scope, file_id)
    sequence = get_next_sequence(scope, file_id)

    %FileRevision{file_id: file_id, inserted_at: DateTime.utc_now(:second)}
    |> FileRevision.changeset(%{
      content: content,
      sequence: sequence
    })
    |> Repo.insert()
  end

  def list_revisions(%Scope{} = scope, file_id) do
    _file = Typster.Files.get_file!(scope, file_id)

    from(r in FileRevision,
      where: r.file_id == ^file_id,
      order_by: [desc: r.sequence]
    )
    |> Repo.all()
  end

  def restore_revision(%Scope{} = scope, revision_id) do
    revision = get_revision!(scope, revision_id)
    file = Typster.Files.get_file!(scope, revision.file_id)

    Typster.Files.update_file_content(scope, file, revision.content)
  end

  defp get_next_sequence(scope, file_id) do
    _file = Typster.Files.get_file!(scope, file_id)

    from(r in FileRevision,
      where: r.file_id == ^file_id,
      select: max(r.sequence)
    )
    |> Repo.one()
    |> case do
      nil -> 1
      max_seq -> max_seq + 1
    end
  end

  def change_revision(%FileRevision{} = revision, attrs \\ %{}) do
    FileRevision.changeset(revision, attrs)
  end
end
