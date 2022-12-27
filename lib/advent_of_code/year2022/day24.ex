defmodule AdventOfCode.Year2022.Day24 do
  @moduledoc """
  --- Day 24: Blizzard Basin ---
  https://adventofcode.com/2022/day/24
  """
  alias AdventOfCode.Grid
  alias AdventOfCode.Math

  # start on the non-wall position in the top row.
  defp start(%Grid{upper_left: {_x, y}} = g),
    do: g |> Grid.row(y) |> Enum.find(fn {_, val} -> val == "." end) |> elem(0)

  # goal is the non-wall position in the bottom row.
  defp goal(%Grid{lower_right: {_x, y}} = g),
    do: g |> Grid.row(y) |> Enum.find(fn {_, val} -> val == "." end) |> elem(0)

  defp in_valley?(%Grid{lower_right: {x1, y1}}, {x, y}),
    do: x > 0 and y > 0 and x < x1 and y < y1

  # calculate the valid moves from the position at time t.
  defp moves(%Grid{} = g, position, t, start, goal) do
    Grid.neighbor_points(position, self: true)
    |> Enum.reject(&blizzard_at?(g, &1, t))
    # consider moves to start or goal or it will never reach the goal. ask me how I know ;(
    |> Enum.filter(&(&1 == start or &1 == goal or in_valley?(g, &1)))
    |> Enum.map(&{&1, t})
  end

  # is a blizzard at position on time t?
  defp blizzard_at?(%Grid{lower_right: {x1, y1}} = g, {x, y}, t) do
    # the blizzards cycle after reaching width/height.
    {width, height} = {x1 - 1, y1 - 1}
    # make zero-indexed to avoid problems with x == height, etc.
    {x, y} = {x - 1, y - 1}
    # if a blizzard moving in the direction is at {x, y} now, it would have been
    # at that point moved t % modulus at the beginning.
    [
      {"^", {x, Math.mod(y + t, height)}},
      {"v", {x, Math.mod(y - t, height)}},
      {"<", {Math.mod(x + t, width), y}},
      {">", {Math.mod(x - t, width), y}}
    ]
    |> Enum.map(fn {b, {x, y}} -> {b, {x + 1, y + 1}} end)
    |> Enum.any?(&blizzard_initially_at?(g, &1))
  end

  # is the specific blizzard initially at the position?
  defp blizzard_initially_at?(%Grid{} = g, {blizzard, position}) do
    case Grid.at(g, position) do
      {:ok, l} when is_list(l) -> blizzard in l
      {:ok, c} when c == blizzard -> true
      _ -> false
    end
  end

  defp shortest_path_length(%Grid{} = g, start_t, start, goal) do
    shortest_path_length([{start, start_t}], MapSet.new(), g, start, goal)
  end

  defp shortest_path_length([{p, t} | queue], visited, %Grid{} = g, start, goal) do
    if p == goal do
      t
    else
      q_tail =
        moves(g, p, t + 1, start, goal)
        |> Enum.filter(&(not MapSet.member?(visited, &1)))

      visited = MapSet.union(visited, MapSet.new(q_tail))
      shortest_path_length(queue ++ q_tail, visited, g, start, goal)
    end
  end

  def part1(input) do
    input
    |> Grid.new()
    |> then(&shortest_path_length(&1, 0, start(&1), goal(&1)))
  end

  def part2(input) do
    g = input |> Grid.new()
    start = start(g)
    goal = goal(g)
    t1 = shortest_path_length(g, 0, start, goal)
    t2 = shortest_path_length(g, t1, goal, start)
    shortest_path_length(g, t2, start, goal)
  end
end
