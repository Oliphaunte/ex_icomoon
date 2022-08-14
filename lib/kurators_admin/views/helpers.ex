defmodule KuratorsAdmin.Helpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML
  use Phoenix.Component

  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

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

  @doc """
  Renders a flash message.
  The rendered flash receives a `:type` that will be used to define
  proper classes to the element, and a `:message` which will be the
  inner HTML, if any exists.
  ## Examples
      <.flash type="info" message="User created" />
  """
  def flash(assigns) do
    if _message = Map.get(assigns.flash, assigns.kind) do
      ~H"""
      <p class={"alert alert-#{@type}"} role="alert" phx-click="lv:clear-flash" phx-value-key={@kind}>
        <%= @message %>
      </p>
      """
    else
      ~H"""

      """
    end
  end

  @doc """
  Returns a button triggered dropdown with aria keyboard and focus supporrt.

  Accepts the follow slots:

    * `:id` - The id to uniquely identify this dropdown
    * `:img` - The optional img to show beside the button title
    * `:title` - The button title
    * `:subtitle` - The button subtitle
    * `:item` - Dropdown list of items

  ## Examples

      <.dropdown id={@id}>
        <:img src={@current_user.avatar_url}/>
        <:title><%= @current_user.name %></:title>
        <:subtitle>@<%= @current_user.username %></:subtitle>

        <:item navigate={profile_path(@current_user)}>View Profile</:item>
        <:item navigate={Routes.settings_path(LiveBeatsWeb.Endpoint, :edit)}Settings</:item>
      </.dropdown>
  """
  def dropdown(assigns) do
    assigns =
      assigns
      |> assign_new(:img, fn -> nil end)
      |> assign_new(:title, fn -> nil end)
      |> assign_new(:subtitle, fn -> nil end)
      |> assign_new(:items, fn -> assigns[:item] end)

    ~H"""
    <!-- User account dropdown -->
    <div class="px-3 relative inline-block text-left">
      <div>
        <button
          id={@id}
          type="button"
          class="group w-full rounded-md px-3.5 py-2 text-sm text-left font-medium text-gray-700 hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-purple-500"
          phx-click={show_dropdown("##{@id}-dropdown")}
          data-active-class="bg-gray-100"
          aria-haspopup="true"
        >
          <span class="flex w-full justify-between items-center">
            <span class="flex min-w-0 items-center justify-between space-x-3">
              <%= for img <- @img do %>
                <img
                  class="w-10 h-10 bg-gray-300 rounded-full flex-shrink-0 ml-4"
                  alt=""
                  {assigns_to_attributes(img)}
                />
              <% end %>
              <span class="flex-1 flex flex-col min-w-0 ml-4">
                <span class="text-gray-900 text-sm font-medium truncate">
                  <%= render_slot(@title) %>
                </span>
                <span class="text-gray-500 text-sm truncate"><%= render_slot(@subtitle) %></span>
              </span>
            </span>
          </span>
        </button>
      </div>
      <div
        id={"#{@id}-dropdown"}
        phx-click-away={hide_dropdown("##{@id}-dropdown")}
        class="hidden z-10 mx-3 origin-top absolute right-0 left-0 mt-1 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 divide-y divide-gray-200"
        role="menu"
        aria-labelledby={@id}
      >
        <div class="py-1" role="none">
          <%= for item <- @items do %>
            <%= if Map.has_key?(item, :patch) do %>
              <.link
                tabindex="-1"
                role="menuitem"
                class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-purple-500"
                {item}
              >
                <%= render_slot(item) %>
              </.link>
            <% else %>
              <%= render_slot(item) %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp show_dropdown(to) do
    JS.show(
      to: to,
      transition:
        {"transition ease-out duration-120", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: to)
  end

  defp hide_dropdown(to) do
    JS.hide(
      to: to,
      transition:
        {"transition ease-in duration-120", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: to)
  end

  @doc """
  Renders a live component inside a modal.
  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <% live_patch("✖",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          ) %>
        <% else %>
          <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  @doc """
  A table helper
  """
  def table(assigns) do
    assigns =
      assigns
      |> assign_new(:row_id, fn -> false end)
      |> assign(:col, for(col <- assigns.col, col[:if] != false, do: col))

    ~H"""
    <div class="hidden mt-8 sm:block">
      <div class="align-middle inline-block min-w-full border-b border-gray-200">
        <table class="min-w-full">
          <thead>
            <tr class="border-t border-gray-200">
              <%= for col <- @col do %>
                <th
                  class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <span class="lg:pl-2"><%= col.label %></span>
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            <%= for {row, i} <- Enum.with_index(@rows) do %>
              <tr id={@row_id && @row_id.(row)} class="hover:bg-gray-50">
                <%= for col <- @col do %>
                  <td class={"px-6 py-3 whitespace-nowrap text-sm font-medium text-gray-900 #{if i == 0, do: "max-w-0 w-full"} #{col[:class]}"}>
                    <div class="flex items-center space-x-3 lg:pl-2">
                      <%= render_slot(col, row) %>
                    </div>
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @doc """
  Renders a dropdown list of navigation links
  """
  def dropdown_nav_list(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= for {[head | tail], counter} <- Enum.with_index(@links) do %>
        <%= if(length(tail) > 0) do %>
          <button
            id={"menu-container-#{counter}"}
            type="button"
            class="bg-white text-gray-600 hover:bg-gray-50 hover:text-gray-900 group w-full flex items-center pl-2 pr-1 py-2 text-left text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            aria-controls="menu-container-#{counter}"
            aria-expanded="false"
            data-open="false"
            phx-click={JS.dispatch("phx:collapse", to: "#menu-container-#{counter}")}
            js-show={show_dropdown_nav_list(counter)}
            js-hide={hide_dropdown_nav_list(counter)}
          >
            <.icon name={head.icon} />

            <span class="flex-1"><%= head.label %></span>

            <.icon
              name="chevron"
              class="transition ease-out duration-120 transform"
              id={"menu-chevron-#{counter}"}
            />
          </button>
        <% else %>
          <.link
            tabindex="1"
            role="sidebar_link"
            class={
              "group w-full flex items-center pl-2 py-2 text-sm font-medium text-gray-600 rounded-md hover:text-gray-900 hover:bg-gray-50 #{if @active_path == head.patch, do: "hover:bg-gray-200 bg-gray-200", else: "hover:bg-gray-50"}"
            }
            {head}
          >
            <.icon name={head.icon} />

            <span class="flex-1"><%= head.label %></span>
          </.link>
        <% end %>

        <%= for item <- tail do %>
          <div class="space-y-1 hidden" id={"sub-menu-#{counter}"}>
            <%= if Map.has_key?(item, :patch) do %>
              <.link
                tabindex="1"
                role="sidebar_link"
                class={
                  "group w-full flex items-center pl-6 pr-2 py-2 text-sm font-medium text-gray-600 rounded-md hover:text-gray-900 hover:bg-gray-50 #{if @active_path == item.patch, do: "hover:bg-gray-200 bg-gray-200", else: "hover:bg-gray-50"}"
                }
                {item}
              >
                <.icon name={item.icon} />
                <%= item.label %>
              </.link>
            <% end %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp show_dropdown_nav_list(counter) do
    %JS{}
    |> JS.toggle(to: "#sub-menu-#{counter}", in: "fade-in-scale", out: "fade-out-scale")
    |> JS.add_class("rotate-90", to: "#menu-chevron-#{counter}")
    |> JS.set_attribute({"data-open", "true"}, to: "#menu-container-#{counter}")
    |> JS.set_attribute({"aria-expanded", "true"}, to: "#menu-container-#{counter}")
  end

  defp hide_dropdown_nav_list(counter) do
    %JS{}
    |> JS.toggle(to: "#sub-menu-#{counter}", in: "fade-in-scale", out: "fade-out-scale")
    |> JS.remove_class("rotate-90", to: "#menu-chevron-#{counter}")
    |> JS.set_attribute({"data-open", "false"}, to: "#menu-container-#{counter}")
    |> JS.set_attribute({"aria-expanded", "false"}, to: "#menu-container-#{counter}")
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(KuratorsAdmin.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(KuratorsAdmin.Gettext, "errors", msg, opts)
    end
  end
end
