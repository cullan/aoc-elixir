defmodule AdventOfCode.Grid do
  alias __MODULE__

  defstruct [:upper_left, :lower_right, :cells]

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

    %Grid{upper_left: {0, 0}, lower_right: lower_right(items), cells: cells}
  end

  def new(size_x, size_y) do
    %Grid{upper_left: {0, 0}, lower_right: {size_x - 1, size_y - 1}, cells: %{}}
  end

  def new(), do: %Grid{upper_left: {0, 0}, lower_right: {0, 0}, cells: %{}}

  defp lower_right(items) do
    {length(hd(items)) - 1, length(items) - 1}
  end

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

  def filter(%Grid{cells: cells}, fun), do: Enum.filter(cells, fun)

  def in_bounds?(%Grid{upper_left: {x1, y1}, lower_right: {x2, y2}}, {x, y})
      when x >= x1 and x <= x2 and y >= y1 and y <= y2,
      do: true

  def in_bounds?(_, _), do: false

  # return the point if it is in bounds, otherwise :error
  defp point_in_grid(%Grid{} = g, point),
    do: if(in_bounds?(g, point), do: {:ok, point}, else: :error)

  def at(%Grid{cells: cells}, point) do
    val = Map.fetch(cells, point)

    case val do
      :error -> :empty
      _ -> val
    end
  end

  def at!(%Grid{cells: cells}, point), do: Map.fetch!(cells, point)

  @doc """
  Move the point in the given direction within the Grid.

  Returns the new point or error if it is out of bounds.
  """
  def move(%Grid{} = g, point, direction), do: g |> point_in_grid(move(point, direction))

  @doc """
  Move the point in the given direction.
  """
  def move(point, direction), do: move_n(point, direction, 1)

  @doc """
  Move the point n spaces in the given direction.
  """
  def move_n({x, y}, :up, n), do: {x, y - n}
  def move_n({x, y}, :down, n), do: {x, y + n}
  def move_n({x, y}, :left, n), do: {x - n, y}
  def move_n({x, y}, :right, n), do: {x + n, y}
  def move_n({x, y}, :up_right, n), do: {x + n, y - n}
  def move_n({x, y}, :up_left, n), do: {x - n, y - n}
  def move_n({x, y}, :down_right, n), do: {x + n, y + n}
  def move_n({x, y}, :down_left, n), do: {x - n, y + n}

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
  def edge_point(%Grid{lower_right: {_x, y}}, {x, _y}, :down), do: {x, y}
  def edge_point(%Grid{}, {_x, y}, :left), do: {0, y}
  def edge_point(%Grid{upper_left: {x, _y}}, {_x, y}, :right), do: {x, y}

  def line_segment(point1, point2, acc \\ [])

  def line_segment(point1, point2, acc) when point1 == point2,
    do: [point1 | acc]

  def line_segment(point1, point2, acc) do
    next_point = move_toward(point2, point1)
    line_segment(point1, next_point, [point2 | acc])
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

  @doc """
  Put the value in the grid at the given point.

  The grid must already be large enough to have that point.
  """
  def put!(%Grid{cells: cells} = g, point, value) do
    true = in_bounds?(g, point)
    %Grid{g | cells: Map.put(cells, point, value)}
  end

  @doc """
  Put the value in the grid at the given point and grow the grid as needed.
  """
  def put(%Grid{} = g, {x, y} = point, value) do
    %{upper_left: {x1, y1}, lower_right: {x2, y2}, cells: cells} = g
    left = {min(x, x1), min(y, y1)}
    right = {max(x, x2), max(y, y2)}
    %Grid{g | upper_left: left, lower_right: right, cells: Map.put(cells, point, value)}
  end

  @doc """
  Find the minimum {x, y} contained in the cells.
  """
  def min_extent(%Grid{cells: cells}) do
    first_point = cells |> Enum.to_list() |> hd() |> elem(0)

    cells
    |> Enum.reduce(first_point, fn {{x, y}, _}, {min_x, min_y} ->
      {min(x, min_x), min(y, min_y)}
    end)
  end

  @doc """
  Find the maximum {x, y} contained in the cells.
  """
  def max_extent(%Grid{cells: cells}) do
    cells
    |> Enum.reduce({0, 0}, fn {{x, y}, _}, {max_x, max_y} ->
      {max(x, max_x), max(y, max_y)}
    end)
  end

  @doc """
  Create a string representation of the grid contents.
  """
  def to_string(%Grid{cells: cells} = g, args \\ []) do
    occupied = args[:occupied] || "#"
    empty = args[:empty] || "."
    {x1, y1} = args[:upper_left] || min_extent(g)
    {x2, y2} = args[:lower_right] || max_extent(g)

    cell_vals =
      for y <- y1..y2,
          x <- x1..x2 do
        if Map.has_key?(cells, {x, y}) do
          if occupied == :val, do: Map.get(cells, {x, y}), else: occupied
        else
          empty
        end
      end

    cell_vals
    |> Enum.chunk_every(x2 - x1 + 1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end
end
