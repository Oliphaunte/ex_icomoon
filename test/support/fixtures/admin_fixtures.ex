defmodule Kurators.AdminFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kurators.Admin` context.
  """

  @doc """
  Generate a route.
  """
  def route_fixture(attrs \\ %{}) do
    {:ok, route} =
      attrs
      |> Enum.into(%{
        name: "some name",
        path: "some path"
      })
      |> Kurators.Admin.create_route()

    route
  end
end
