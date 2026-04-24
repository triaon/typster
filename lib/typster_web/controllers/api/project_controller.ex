defmodule TypsterWeb.Api.ProjectController do
  use TypsterWeb, :controller

  alias Typster.Projects

  def index(conn, _params) do
    projects = Projects.list_projects(conn.assigns.current_scope)
    json(conn, %{projects: Enum.map(projects, &project_json/1)})
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.create_project(conn.assigns.current_scope, project_params) do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> json(%{project: project_json(project)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors_on(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(conn.assigns.current_scope, id)
    json(conn, %{project: project_json(project)})
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    scope = conn.assigns.current_scope
    project = Projects.get_project!(scope, id)

    case Projects.update_project(scope, project, project_params) do
      {:ok, project} ->
        json(conn, %{project: project_json(project)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors_on(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope
    project = Projects.get_project!(scope, id)
    {:ok, _project} = Projects.delete_project(scope, project)

    send_resp(conn, :no_content, "")
  end

  defp project_json(project) do
    %{
      id: project.id,
      name: project.name,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
