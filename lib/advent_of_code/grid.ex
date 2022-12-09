defmodule AdventOfCode.Grid do
  alias __MODULE__

  defstruct [:dimensions, :cells]

  def new(items) do
    cells =
      items
      |> Enum.reduce({%{}, 0}, fn row, {acc, y} ->
        row_map =
          row
          |> Stream.with_index()
          |> Enum.map(fn {item, x} -> {{x, y}, item} end)
          |> Map.new()

        {Map.merge(acc, row_map), y + 1}
      end)
      |> elem(0)

    %Grid{dimensions: dimensions(items), cells: cells}
  end

  defp dimensions(items) do
    {length(hd(items)), length(items)}
  end

  def in_bounds?(%Grid{dimensions: {l, h}}, {x, y}) when x >= 0 and x < l and y >= 0 and y < h,
    do: true

  def in_bounds?(_, _), do: false

  @doc """
  Traverse the cells of the grid and collect the results of running the function on each cell.

  fun/3 takes %Grid{}, {x, y}, val
  """
  def traverse(%Grid{cells: cells} = g, fun) do
    cells
    |> Enum.map(fn {point, val} ->
      fun.(g, point, val)
    end)
  end

  defp point_or_error(%Grid{} = g, point) do
    if in_bounds?(g, point), do: {:ok, point}, else: :error
  end

  def look(%Grid{} = g, {x, y}, :up), do: point_or_error(g, {x, y - 1})
  def look(%Grid{} = g, {x, y}, :down), do: point_or_error(g, {x, y + 1})
  def look(%Grid{} = g, {x, y}, :left), do: point_or_error(g, {x - 1, y})
  def look(%Grid{} = g, {x, y}, :right), do: point_or_error(g, {x + 1, y})

  def at(%Grid{cells: cells}, point), do: Map.fetch(cells, point)
  def at!(%Grid{cells: cells}, point), do: Map.fetch!(cells, point)

  def move_toward(%Grid{} = g, point1, point2),
    do: point_or_error(g, move_toward_helper(point1, point2))

  defp move_toward_helper({x1, y1}, {x2, y2}) do
    cond do
      # move right
      x2 > x1 and y2 == y1 -> {x1 + 1, y1}
      # move left
      x2 < x1 and y2 == y1 -> {x1 - 1, y1}
      # move up
      x2 == x1 and y2 < y1 -> {x1, y1 - 1}
      # move down
      x2 == x1 and y2 > y1 -> {x1, y1 + 1}
      # diagonal up right
      x2 > x1 and y2 < y1 -> {x1 + 1, y1 - 1}
      # diagonal up left
      x2 < x1 and y2 < y1 -> {x1 - 1, y1 - 1}
      # diagonal down right
      x2 > x1 and y2 > y1 -> {x1 + 1, y1 + 1}
      # diagonal down left
      x2 < x1 and y2 > y1 -> {x1 - 1, y1 + 1}
    end
  end

  @doc """
  Find the point on the edge heading in the specified direction from the point.
  """
  def edge_point(%Grid{}, {x, _y}, :up), do: {x, 0}
  def edge_point(%Grid{dimensions: {_l, h}}, {x, _y}, :down), do: {x, h - 1}
  def edge_point(%Grid{}, {_x, y}, :left), do: {0, y}
  def edge_point(%Grid{dimensions: {l, _h}}, {_x, y}, :right), do: {l - 1, y}

  def line_segment(grid, point1, point2, acc \\ [])

  def line_segment(%Grid{}, point1, point2, acc) when point1 == point2,
    do: [point1 | acc]

  def line_segment(%Grid{} = g, point1, point2, acc) do
    {:ok, next_point} = move_toward(g, point2, point1)
    line_segment(g, point1, next_point, [point2 | acc])
  end

  def line_segment_to_edge(%Grid{} = g, point, direction),
    do: line_segment_to_edge(g, point, direction, []) |> Enum.reverse()

  def line_segment_to_edge(%Grid{} = g, point, direction, acc) do
    with {:ok, next_point} <- look(g, point, direction) do
      line_segment_to_edge(g, next_point, direction, [next_point | acc])
    else
      :error -> acc
    end
  end
end
