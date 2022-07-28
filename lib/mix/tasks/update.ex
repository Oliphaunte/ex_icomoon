defmodule Mix.Tasks.Kurators.Update do
  @moduledoc """
  """

  use Mix.Task
  require IEx

  @shortdoc "Updates Kurators"

  def run(_args) do
    Mix.shell().info([:cyan, "\n Updating Kurators...\n"])

    Mix.shell().yes?(
      "You are updating Kurators, this is will override existing files, are you sure you wish to continue?"
    )
  end
end
