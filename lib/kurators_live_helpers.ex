defmodule Kurators.LiveHelpers do
  use Phoenix.HTML

  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  def icon(assigns) do
    assigns =
      assigns
      |> assign_new(:outlined, fn -> false end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:id, fn -> "" end)
      |> assign_new(:"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    ~H"""
    <svg id={@id} class={"icon icon-home text-indigo-500 mr-3 flex-shrink-0 h-6 w-6 #{@class}"}>
      <use xlink:href={"#icon-#{@name}"}></use>
    </svg>
    """
  end
end
