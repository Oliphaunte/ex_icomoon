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

  def link(%{navigate: _to} = assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)

    ~H"""
    <a href={@navigate} data-phx-link="redirect" data-phx-link-state="push" class={@class}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def link(%{patch: to} = assigns) do
    opts = assigns |> assigns_to_attributes() |> Keyword.put(:to, to)
    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= live_patch @opts do %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end

  def link(%{} = assigns) do
    opts = assigns |> assigns_to_attributes() |> Keyword.put(:to, assigns[:href] || "#")
    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= Phoenix.HTML.Link.link @opts do %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end
end
