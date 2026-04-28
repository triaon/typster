defmodule Typster.ProjectsFixtures do
  @moduledoc false

  alias Typster.Accounts.Scope
  alias Typster.Assets
  alias Typster.Files
  alias Typster.Projects

  def project_fixture(scope_or_user \\ nil, attrs \\ %{}) do
    scope = ensure_scope(scope_or_user)

    {:ok, project} =
      Projects.create_project(
        scope,
        Enum.into(attrs, %{name: "Project #{System.unique_integer([:positive])}"})
      )

    project
  end

  def file_fixture(project, scope_or_user \\ nil, attrs \\ %{}) do
    scope = ensure_scope(scope_or_user || project.user)

    {:ok, file} =
      Files.create_file(
        scope,
        project.id,
        Enum.into(attrs, %{path: "main.typ", content: "= Hello"})
      )

    file
  end

  def asset_fixture(project, scope_or_user \\ nil, attrs \\ %{}) do
    scope = ensure_scope(scope_or_user || project.user)
    object_key = "projects/#{project.id}/assets/#{System.unique_integer([:positive])}-logo.png"

    {:ok, asset} =
      Assets.upload_asset(
        scope,
        project.id,
        object_key,
        Enum.into(attrs, %{filename: "logo.png", content_type: "image/png", size: 128})
      )

    asset
  end

  defp ensure_scope(%Scope{} = scope), do: scope
  defp ensure_scope(%Typster.Accounts.User{} = user), do: Scope.for_user(user)
  defp ensure_scope(nil), do: Scope.for_user(Typster.AccountsFixtures.user_fixture())
end
