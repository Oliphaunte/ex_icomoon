defmodule ExIcomoon do
  # TODO: Auto-load changes to this hex package.
  # TODO: Enable specifying your Icomoon code w/ 1PW.
  # TODO: Add docs.

  @moduledoc """
  Documentation for `ExIcomoon`.
  """

  use Phoenix.HTML

  require Logger

  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers
  import Phoenix.Component

  @tailwind_to_view_box 4

  @doc """
  """
  @spec icon(Map.t()) :: Phoenix.LiveView.Rendered.t()
  def icon(assigns) do
    assigns =
      assigns
      |> assign_new(:outlined, fn -> false end)
      |> assign_new(:id, fn -> "#{assigns[:name]}_icon" end)
      |> assign_new(:type, fn -> "" end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:stroke, fn -> "" end)
      |> assign_new(:"stroke-width", fn -> "" end)
      |> assign_new(:fill, fn -> "" end)
      |> assign_new(:viewBox, fn -> get_view_box_from_classes(assigns[:class]) end)
      # TODO: Describe behavior better.
      # If there is no `aria-label` attribute, hide it from screen readers with `aria-hidden`.
      # TODO: Ensure that @aria-hidden has a consistent type, either "true" or true.
      |> assign_new(:"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    # TODO: Refactor.
    assigns =
      if assigns[:"aria-hidden"] == false || assigns[:"aria-hidden"] == "false" do
        Logger.debug("aria-hidden is false, so keeping the aria-label attribute")
        assigns |> assign_new(:"aria-label", fn -> assigns[:name] end)
      else
        assigns
      end

    Logger.info("assigns: #{inspect(assigns)}")

    # TODO: Refactor.
    stroke_fill =
      case assigns[:type] do
        "outline" ->
          %{:stroke => "currentColor", :fill => "none"}

        "solid" ->
          %{:stroke => "none", :fill => "currentColor"}

        _ ->
          %{:stroke => "none", :fill => "currentColor"}
      end

    Logger.debug("stroke_fill: #{inspect(stroke_fill)}")

    assigns = Map.merge(assigns, stroke_fill)
    Logger.debug("assigns: #{inspect(assigns)}")

    # TODO: Add a splat to pass attributes through.
    # TODO: Latest SVG version & XMLNS.
    # TODO: Match order of properties in Heroicons SVGs.
    ~H"""
    <svg
      id={@id}
      class={@class}
      stroke={@stroke}
      stroke-width={assigns[:"stroke-width"]}
      fill={@fill}
      viewBox={@viewBox}
      aria-hidden={"#{assigns[:"aria-hidden"]}"}
      aria-label={assigns[:"aria-label"]}
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
    >
      <%= if @type != "" do %>
        <use xlink:href={"#icon-#{@type}-#{@name}"}></use>
      <% else %>
        <use xlink:href={"#icon-#{@name}"}></use>
      <% end %>
    </svg>
    """
  end

  @spec get_view_box_from_classes(String.t()) :: String.t()
  def get_view_box_from_classes(class_string) do
    dimensions = get_dimensions_from_classes(class_string)
    view_box = get_view_box_from_dimensions(dimensions)
    view_box
  end

  @spec get_dimensions_from_classes(String.t()) :: Map.t()
  def get_dimensions_from_classes(class_string) do
    Logger.info("view_box_dims: #{inspect(class_string)}")

    class_array = ~w(#{class_string})
    Logger.debug("classes: #{inspect(class_array)}")

    dimensions =
      class_array
      |> Enum.map(fn class ->
        Logger.debug("class: #{inspect(class)}")

        regex = ~r/^(?<dimension>w|h)-(?<value>[[:digit:]]+)$/
        dimension_value = Regex.named_captures(regex, class)

        dim_num =
          if dimension_value do
            Logger.debug("dimension_value: #{inspect(dimension_value)}")

            dimension = dimension_value["dimension"]
            value = dimension_value["value"]
            Logger.debug("dimension: #{inspect(dimension)}, value: #{inspect(value)}")

            %{dimension => value}
          else
            Logger.debug("no dimension value")

            nil
          end

        Logger.debug("dim_num: #{inspect(dim_num)}")

        dim_num
      end)
      |> Enum.reject(&is_nil(&1))

    dimensions =
      if(Enum.empty?(dimensions)) do
        Logger.debug("no dimensions found")

        Logger.warn(
          "Include the icon's dimensions in its Tailwind classes: class='h-5 w-5 text-red-500'"
        )

        %{}
      else
        Logger.debug("dimensions found")

        dimensions |> Enum.reduce(&Map.merge/2)
      end

    Logger.debug("dimensions: #{inspect(dimensions)}")

    dimensions
  end

  @spec get_view_box_from_dimensions(Map.t()) :: String.t()
  def get_view_box_from_dimensions(dimensions_map) do
    Logger.info("dimensions_map: #{inspect(dimensions_map)}")

    css_width = dimensions_map["w"]
    css_height = dimensions_map["h"]
    Logger.debug("css_width: #{inspect(css_width)}, css_height: #{inspect(css_height)}")

    view_box_width = String.to_integer(css_width) * @tailwind_to_view_box
    view_box_height = String.to_integer(css_height) * @tailwind_to_view_box

    Logger.debug(
      "view_box_width: #{inspect(view_box_width)}, view_box_height: #{inspect(view_box_height)}"
    )

    view_box = "0 0 #{view_box_width} #{view_box_height}"
    Logger.debug("view_box: #{inspect(view_box)}")

    view_box
  end
end
