defmodule Kurators.Auth.SignInCodeHandler do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end
end
