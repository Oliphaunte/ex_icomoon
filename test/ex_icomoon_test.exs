defmodule ExIcomoonTest do
  use ExUnit.Case
  doctest ExIcomoon

  # TODO: Test view box functionality.

  # TODO: Test that `aria-*` attributes are correctly set.

  test "greets the world" do
    assert ExIcomoon.hello() == :world
  end
end
