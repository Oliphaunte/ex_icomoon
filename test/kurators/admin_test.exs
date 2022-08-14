defmodule Kurators.AdminTest do
  use Kurators.DataCase

  alias Kurators.Admin

  describe "routes" do
    alias Kurators.Admin.Route

    import Kurators.AdminFixtures

    @invalid_attrs %{name: nil, path: nil}

    test "list_routes/0 returns all routes" do
      route = route_fixture()
      assert Admin.list_routes() == [route]
    end

    test "get_route!/1 returns the route with given id" do
      route = route_fixture()
      assert Admin.get_route!(route.id) == route
    end

    test "create_route/1 with valid data creates a route" do
      valid_attrs = %{name: "some name", path: "some path"}

      assert {:ok, %Route{} = route} = Admin.create_route(valid_attrs)
      assert route.name == "some name"
      assert route.path == "some path"
    end

    test "create_route/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Admin.create_route(@invalid_attrs)
    end

    test "update_route/2 with valid data updates the route" do
      route = route_fixture()
      update_attrs = %{name: "some updated name", path: "some updated path"}

      assert {:ok, %Route{} = route} = Admin.update_route(route, update_attrs)
      assert route.name == "some updated name"
      assert route.path == "some updated path"
    end

    test "update_route/2 with invalid data returns error changeset" do
      route = route_fixture()
      assert {:error, %Ecto.Changeset{}} = Admin.update_route(route, @invalid_attrs)
      assert route == Admin.get_route!(route.id)
    end

    test "delete_route/1 deletes the route" do
      route = route_fixture()
      assert {:ok, %Route{}} = Admin.delete_route(route)
      assert_raise Ecto.NoResultsError, fn -> Admin.get_route!(route.id) end
    end

    test "change_route/1 returns a route changeset" do
      route = route_fixture()
      assert %Ecto.Changeset{} = Admin.change_route(route)
    end
  end
end
