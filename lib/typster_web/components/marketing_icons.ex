defmodule TypsterWeb.MarketingIcons do
  @moduledoc """
  Inline SVG icons for the marketing landing page.

  Source files live in `priv/static/images/icons/*.svg`. Their contents
  are read at compile time and inlined into the rendered HTML so that
  `currentColor` continues to work for theme-aware coloring.

  Updating an SVG on disk triggers a recompile via `@external_resource`.
  """
  use Phoenix.Component

  @icons_dir Path.expand("../../../priv/static/images/icons", __DIR__)

  @doc """
  Render an SVG icon by file name (without extension).

      <.mk_icon name="arrow-right" class="mk-icon-14" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def mk_icon(assigns) do
    assigns = assign(assigns, :__svg__, render_svg(assigns.name, assigns.class, assigns.rest))

    ~H"""
    {Phoenix.HTML.raw(@__svg__)}
    """
  end

  for filename <- @icons_dir |> File.ls!() |> Enum.sort(),
      String.ends_with?(filename, ".svg") do
    name = Path.rootname(filename)
    path = Path.join(@icons_dir, filename)
    @external_resource path

    contents = path |> File.read!() |> String.trim()

    defp render_svg(unquote(name), class, rest) do
      inject_attrs(unquote(contents), class, rest)
    end
  end

  defp render_svg(name, _class, _rest) do
    raise ArgumentError, "unknown marketing icon: #{inspect(name)}"
  end

  defp inject_attrs(svg, class, rest) do
    attrs =
      [{"class", class} | Map.to_list(rest || %{})]
      |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
      |> Enum.map(fn {k, v} -> ~s( #{k}="#{escape(v)}") end)
      |> IO.iodata_to_binary()

    String.replace(svg, "<svg", "<svg" <> attrs, global: false)
  end

  defp escape(value) do
    value
    |> to_string()
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
  end
end
