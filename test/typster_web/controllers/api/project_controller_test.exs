defmodule TypsterWeb.Api.ProjectControllerTest do
  use TypsterWeb.ConnCase, async: true

  import Typster.AccountsFixtures
  import Typster.ProjectsFixtures

  test "GET /api/health returns app status", %{conn: conn} do
    conn = get(conn, ~p"/api/health")

    assert %{"status" => "ok", "app" => "typster"} = json_response(conn, 200)
  end

  test "GET /api/projects requires authentication", %{conn: conn} do
    conn = get(conn, ~p"/api/projects")

    assert %{"error" => "unauthorized"} = json_response(conn, 401)
  end

  test "POST /api/users/log-in returns bearer token for valid credentials", %{conn: conn} do
    user = user_fixture() |> set_password()

    conn =
      post(conn, ~p"/api/users/log-in", %{
        "email" => user.email,
        "password" => valid_user_password()
      })

    assert %{"token" => token} = json_response(conn, 200)
    assert is_binary(token)
  end

  test "authenticated project and file endpoints are scoped to the current user", %{conn: conn} do
    user = user_fixture() |> set_password()
    other_user = user_fixture()

    user_project = project_fixture(user, %{name: "Owned Project"})
    file_fixture(user_project, user, %{path: "main.typ", content: "= Owned"})

    _other_project = project_fixture(other_user, %{name: "Other Project"})

    token = bearer_token_for(user)
    conn = put_req_header(conn, "authorization", "Bearer " <> token)

    conn = get(conn, ~p"/api/projects")
    assert %{"projects" => [%{"id" => id, "name" => "Owned Project"}]} = json_response(conn, 200)
    assert id == user_project.id

    conn =
      post(conn, ~p"/api/projects/#{user_project.id}/files", %{
        "file" => %{"path" => "refs.bib", "content" => "@book{a}"}
      })

    assert %{"file" => %{"path" => "refs.bib", "kind" => "text", "language" => "bibtex"}} =
             json_response(conn, 201)
  end

  defp bearer_token_for(user) do
    user
    |> Typster.Accounts.generate_user_session_token()
    |> Base.url_encode64(padding: false)
  end
end
