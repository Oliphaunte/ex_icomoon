defmodule <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Auth.Supervisor do
  use Supervisor

  alias <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Auth.{TokenHandler, SignInCodeHandler}

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [TokenHandler, SignInCodeHandler]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
