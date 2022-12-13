defmodule AdventOfCode.Year2022.Day12 do
  @moduledoc """
  --- Day 12: Hill Climbing Algorithm ---
  https://adventofcode.com/2022/day/12
  """

  alias AdventOfCode.Grid

  defp make_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> Grid.new()
  end

  defp find_start_point(%Grid{} = g, start_val),
    do: Grid.find_point(g, fn {_point, val} -> val == start_val end)

  defp valid_move?(?S, b), do: valid_move?(?a, b)
  defp valid_move?(a, ?E), do: valid_move?(a, ?z)
  defp valid_move?(a, b) when b > a + 1, do: false
  defp valid_move?(_, _), do: true

  defp potential_moves(%Grid{} = g, test, point) do
    val = Grid.at!(g, point)

    g
    |> Grid.neighbors(point)
    |> Enum.map(fn point -> {point, Grid.at!(g, point)} end)
    |> Enum.filter(fn {_, neighbor_val} -> test.(val, neighbor_val) end)
    |> Enum.map(&elem(&1, 0))
  end

  defp shortest_path(%Grid{} = g, test, args \\ []) do
    start = args[:start] || ?S
    goal = args[:goal] || ?E
    start_point = find_start_point(g, start)

    queue = :queue.new()
    queue = :queue.in({start_point, []}, queue)

    g
    |> shortest_path(goal, test, queue, MapSet.new())
    |> Enum.reverse()
  end

  defp shortest_path(%Grid{} = g, goal, test, queue, visited) do
    {{:value, {point, path}}, queue} = :queue.out(queue)
    path = [point | path]
    val = Grid.at!(g, point)

    cond do
      val == goal ->
        path

      true ->
        visited = MapSet.put(visited, point)
        moves = potential_moves(g, test, point) |> Enum.filter(&(not MapSet.member?(visited, &1)))
        queue = moves |> Enum.reduce(queue, &:queue.in({&1, path}, &2))
        shortest_path(g, goal, test, queue, MapSet.union(visited, MapSet.new(moves)))
    end
  end

  def part1(input) do
    path =
      input
      |> make_grid()
      |> shortest_path(&valid_move?/2)

    length(path) - 1
  end

  def part2(input) do
    path =
      input
      |> make_grid()
      |> shortest_path(&valid_move?(&2, &1), start: ?E, goal: ?a)

    length(path) - 1
  end
end
