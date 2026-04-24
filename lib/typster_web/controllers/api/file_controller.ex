defmodule TypsterWeb.Api.FileController do
  use TypsterWeb, :controller

  alias Typster.Files

  def index(conn, %{"project_id" => project_id}) do
    files = Files.get_file_tree(conn.assigns.current_scope, project_id)
    json(conn, %{files: Enum.map(files, &file_json/1)})
  end

  def create(conn, %{"project_id" => project_id, "file" => file_params}) do
    case Files.create_file(conn.assigns.current_scope, project_id, file_params) do
      {:ok, file} ->
        conn
        |> put_status(:created)
        |> json(%{file: file_json(file)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors_on(changeset)})
    end
  end

  def update(conn, %{"id" => id, "file" => file_params}) do
    scope = conn.assigns.current_scope
    file = Files.get_file!(scope, id)

    case Files.update_file(scope, file, file_params) do
      {:ok, file} ->
        json(conn, %{file: file_json(file)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors_on(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope
    file = Files.get_file!(scope, id)
    {:ok, _file} = Files.delete_file(scope, file)

    send_resp(conn, :no_content, "")
  end

  defp file_json(file) do
    %{
      id: file.id,
      path: file.path,
      content: file.content,
      kind: Files.file_kind(file),
      language: Files.editor_language(file.path),
      inserted_at: file.inserted_at,
      updated_at: file.updated_at
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
