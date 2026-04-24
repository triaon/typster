defmodule Typster.Jobs.AssetCleanup do
  @moduledoc "Oban job that deletes assets whose parent project no longer exists"
  use Oban.Worker, queue: :default, max_attempts: 3

  @impl Oban.Worker
  def perform(_job) do
    alias Typster.Repo

    import Ecto.Query

    all_assets = Repo.all(Typster.Assets.Asset)

    all_project_ids =
      Repo.all(
        from p in Typster.Projects.Project,
          select: p.id
      )
      |> Enum.map(& &1.id)

    orphaned_assets =
      Enum.filter(all_assets, fn asset ->
        not Enum.member?(all_project_ids, asset.project_id)
      end)

    Enum.each(orphaned_assets, fn asset ->
      Repo.delete(asset)
    end)

    :ok
  end
end
