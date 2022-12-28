defmodule AdventOfCode.Grid do
  alias __MODULE__

  defstruct [:upper_left, :lower_right, :cells]

  def new(items) when is_list(items) do
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

  def new(s, transform \\ &default_cell_transform/2) when is_binary(s) do
    s
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Enum.reduce(new(), fn {row, row_num}, row_g ->
      row
      |> String.codepoints()
      |> Stream.with_index()
      |> Enum.reduce(row_g, fn {val, col_num}, col_g ->
        case transform.(col_g, {{col_num, row_num}, val}) do
          nil -> col_g
          new_val -> put(col_g, {col_num, row_num}, new_val)
        end
      end)
    end)
  end

  def new(), do: %Grid{upper_left: {0, 0}, lower_right: {0, 0}, cells: %{}}

  # transforms cell contents.
  # default aoc maps usually have # for occupied spaces, . for open spaces.
  #
  # sometimes there is a " " (space char) that is in the string, but not part of
  # the map. those should be discarded.
  defp default_cell_transform(%Grid{}, {_position, c}) do
    case c do
      " " -> nil
      _ -> c
    end
  end

  defp lower_right(items) do
    {length(hd(items)) - 1, length(items) - 1}
  end

  @doc """
  Return the results of running the function on each cell.

  fun/2 takes %Grid{}, {{x, y}, val}
  """
  def map(%Grid{cells: cells} = g, fun), do: cells |> Enum.map(&fun.(g, &1))

  @doc """
  Filters the cells, i.e. returns only those elements for which fun returns a truthy value.

  fun/2 takes %Grid{}, {{x, y}, val}
  """
  def filter(%Grid{cells: cells} = g, fun), do: cells |> Enum.filter(&fun.(g, &1))

  @doc """
  Returns the cells, excluding those for which fun returns a truthy value.

  fun/2 takes %Grid{}, {{x, y}, val}
  """
  def reject(%Grid{cells: cells} = g, fun), do: cells |> Enum.reject(&fun.(g, &1))

  @doc """
  Invokes fun for each cell with the accumulator.

  fun/3 takes %Grid{}, {{x, y}, val}, acc
  """
  def reduce(%Grid{cells: cells} = g, acc, fun), do: cells |> Enum.reduce(acc, &fun.(g, &1, &2))

  @doc """
  Return a list of the cells in the given row.
  """
  def row(%Grid{cells: cells}, row) do
    cells
    |> Enum.filter(fn {{_x, y}, _val} -> y == row end)
    |> Enum.sort_by(&elem(&1, 0))
  end

  @doc """
  Return a list of the cells in the given column.
  """
  def col(%Grid{cells: cells}, col) do
    cells
    |> Enum.filter(fn {{x, _y}, _val} -> x == col end)
    |> Enum.sort_by(&elem(&1, 0))
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

  def neighbor_points(point, args \\ []) do
    diagonals? = args[:diagonals] || false
    diagonal_directions = [:up_left, :up_right, :down_left, :down_right]
    self? = args[:self] || false

    [:up, :down, :left, :right]
    |> Enum.concat(if diagonals?, do: diagonal_directions, else: [])
    |> Enum.map(&move(point, &1))
    |> Enum.concat(if self?, do: [point], else: [])
  end

  def neighbors(%Grid{} = g, {_x, _y} = point, args \\ []) do
    neighbor_points(point, args)
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
  Put the val in all the cells that are currently empty.
  """
  def fill_empty(%Grid{upper_left: {x1, y1}, lower_right: {x2, y2}} = g, val) do
    for(x <- x1..x2, y <- y1..y2, do: {x, y})
    |> Enum.reduce(g, fn {x, y}, g ->
      case Grid.at(g, {x, y}) do
        :empty -> Grid.put(g, {x, y}, val)
        _ -> g
      end
    end)
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
    cell_fmt = args[:cell_fmt] || (& &1)
    default = args[:default] || " "
    {x1, y1} = args[:upper_left] || min_extent(g)
    {x2, y2} = args[:lower_right] || max_extent(g)

    cell_vals =
      for y <- y1..y2,
          x <- x1..x2 do
        cells
        |> Map.get({x, y}, default)
        |> cell_fmt.()
      end

    cell_vals
    |> Enum.chunk_every(x2 - x1 + 1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end
end
