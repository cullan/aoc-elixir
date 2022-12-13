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

  @doc """
  Return the first cell for which fun returns a truthy value. If no such element is found, returns nil.

  fun/1 arg is a tuple: {{x, y}, cell_val}
  """
  def find(%Grid{cells: cells}, fun), do: Enum.find(cells, fun)

  def find_point(%Grid{} = g, fun) do
    g
    |> Grid.find(fun)
    |> elem(0)
  end

  # return the point if it is in bounds, otherwise :error
  defp point_in_grid(%Grid{} = g, point),
    do: if(in_bounds?(g, point), do: {:ok, point}, else: :error)

  def at(%Grid{cells: cells}, point), do: Map.fetch(cells, point)
  def at!(%Grid{cells: cells}, point), do: Map.fetch!(cells, point)

  @doc """
  Move the point in the given direction within the Grid.

  Returns the new point or error if it is out of bounds.
  """
  def move(%Grid{} = g, point, direction), do: g |> point_in_grid(move(point, direction))

  @doc """
  Move the point in the given direction.
  """
  def move({x, y}, :up), do: {x, y - 1}
  def move({x, y}, :down), do: {x, y + 1}
  def move({x, y}, :left), do: {x - 1, y}
  def move({x, y}, :right), do: {x + 1, y}
  def move({x, y}, :up_right), do: {x + 1, y - 1}
  def move({x, y}, :up_left), do: {x - 1, y - 1}
  def move({x, y}, :down_right), do: {x + 1, y + 1}
  def move({x, y}, :down_left), do: {x - 1, y + 1}

  @doc """
  Move the point toward the other point within the Grid.

  Returns the new point or error if it is out of bounds.
  """
  def move_toward(%Grid{} = g, point1, point2), do: point_in_grid(g, move_toward(point1, point2))

  @doc """
  Move the point toward the other point.
  """
  def move_toward({x1, y1} = p, {x2, y2}) do
    cond do
      x2 > x1 and y2 == y1 -> move(p, :right)
      x2 < x1 and y2 == y1 -> move(p, :left)
      x2 == x1 and y2 < y1 -> move(p, :up)
      x2 == x1 and y2 > y1 -> move(p, :down)
      x2 > x1 and y2 < y1 -> move(p, :up_right)
      x2 < x1 and y2 < y1 -> move(p, :up_left)
      x2 > x1 and y2 > y1 -> move(p, :down_right)
      x2 < x1 and y2 > y1 -> move(p, :down_left)
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
    with {:ok, next_point} <- move(g, point, direction) do
      line_segment_to_edge(g, next_point, direction, [next_point | acc])
    else
      :error -> acc
    end
  end

  def neighbors(%Grid{} = g, point, args \\ []) do
    diagonals? = args[:diagonals] || false
    diagonal_directions = [:up_left, :up_right, :down_left, :down_right]

    [:up, :down, :left, :right]
    |> Enum.concat(if diagonals?, do: diagonal_directions, else: [])
    |> Enum.map(&move(point, &1))
    |> Enum.filter(&in_bounds?(g, &1))
  end

  def put(%Grid{cells: cells} = g, point, value),
    do: %Grid{g | cells: Map.put(cells, point, value)}
end
