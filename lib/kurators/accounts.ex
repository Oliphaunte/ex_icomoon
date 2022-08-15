defmodule Kurators.Accounts do
  @moduledoc """
  Authentication piece that allows users to login via either their email/code or 3rd party

  TODO: 2-factor auth (yubikey?)
  """
  use Ecto.Schema

  alias Kurators.Accounts.User

  @pubsub Kurators.PubSub

  defp topic(user_id), do: "users:#{user_id}"

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(user_id))
  end

  def unsubscribe(user_id) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(user_id))
  end

  defp broadcast!(%User{} = user, msg) do
    Phoenix.PubSub.broadcast!(@pubsub, topic(user.id), {__MODULE__, msg})
  end
end
