defmodule AdventOfCode.Year2022.Day14 do
  @moduledoc """
  --- Day 14: Regolith Reservoir ---
  https://adventofcode.com/2022/day/14
  """

  alias AdventOfCode.Grid

  defp make_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> path_points()
      |> line_segments()
    end)
    |> Enum.reduce(Grid.new(), &add_line_segments/2)
    |> Map.put(:full, false)
  end

  # "498,4 -> 498,6 -> 496,6" => [{498, 4}, {498, 6}, {496, 6}]
  defp path_points(s), do: s |> String.split(" -> ") |> Enum.map(&point/1)

  # "498,4" => {498, 4}
  defp point(s), do: s |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()

  # make a list of line segment begin end end points
  # [{498, 4}, {498, 6}, {496, 6}] => [[{498, 4}, {498, 6}], [{498, 6}, {496, 6}]]
  defp line_segments(path_points) do
    path_points
    |> Enum.chunk_every(2, 1, :discard)
  end

  defp add_line_segments(path, g), do: Enum.reduce(path, g, &add_line_segment/2)

  defp add_line_segment([point1, point2], %Grid{} = g) do
    Grid.line_segment(point1, point2)
    |> Enum.reduce(g, &Grid.put(&2, &1, "#"))
  end

  defp drop_sand(%Grid{} = g, sand_point \\ {500, 0}) do
    next = next_sand_point(g, sand_point)

    cond do
      next == {500, 0} or falling?(g, next) ->
        Map.put(g, :full, true)

      sand_point == next ->
        Grid.put(g, sand_point, "o")

      true ->
        drop_sand(g, next)
    end
  end

  defp falling?(%Grid{lower_right: {_l, y1}}, {_x, y}), do: y > y1

  defp next_sand_point(%Grid{} = g, point) do
    next =
      [:down, :down_left, :down_right]
      |> Stream.map(&Grid.move(point, &1))
      |> Stream.filter(&(at(g, &1) == :empty))
      |> Enum.take(1)

    case next do
      [p] -> p
      _ -> point
    end
  end

  defp at(%Grid{} = g, {_x, y} = point) do
    if y == Map.get(g, :floor_level, :no_floor) do
      "#"
    else
      Grid.at(g, point)
    end
  end

  defp rounds_until_overflow(%Grid{} = g) do
    g
    |> Stream.iterate(&drop_sand/1)
    |> Stream.with_index(0)
    |> Stream.drop_while(&(not elem(&1, 0).full))
    |> Enum.take(1)
    |> hd()
    |> elem(1)
  end

  defp set_floor_level(%Grid{lower_right: {x, _y}} = g) do
    {_x, y} = Grid.max_extent(g)

    g
    |> Map.put(:floor_level, y + 2)
    |> Map.put(:lower_right, {x, y + 3})
  end

  def debug(g),
    do: IO.puts(Grid.to_string(g, occupied: :val, upper_left: {488, 0}, lower_right: {510, 12}))

  def part1(input) do
    overflow_round =
      input
      |> make_grid()
      |> rounds_until_overflow()

    overflow_round - 1
  end

  def part2(input) do
    overflow_round =
      input
      |> make_grid()
      |> set_floor_level()
      |> rounds_until_overflow()

    overflow_round
  end
end
