defmodule KuratorsWeb.AuthLive do
  use KuratorsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end