defmodule Typster.ProjectsTest do
  use Typster.DataCase, async: true

  import Typster.AccountsFixtures
  import Typster.ProjectsFixtures

  alias Typster.Accounts.Scope
  alias Typster.Projects

  describe "project scoping" do
    test "create_project/2 assigns ownership to the current scope user" do
      user = user_fixture()
      scope = Scope.for_user(user)

      {:ok, project} = Projects.create_project(scope, %{name: "Owned"})

      assert project.user_id == user.id
    end

    test "list_projects/1 only returns projects for the current scope user" do
      user = user_fixture()
      other_user = user_fixture()

      visible = project_fixture(user, %{name: "Visible"})
      _hidden = project_fixture(other_user, %{name: "Hidden"})

      assert [project] = Projects.list_projects(Scope.for_user(user))
      assert project.id == visible.id
    end

    test "get_project!/2 rejects access to another user's project" do
      user = user_fixture()
      other_user = user_fixture()
      project = project_fixture(other_user)

      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project!(Scope.for_user(user), project.id)
      end
    end
  end
end
