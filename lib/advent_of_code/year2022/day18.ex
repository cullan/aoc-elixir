defmodule AdventOfCode.Year2022.Day18 do
  @moduledoc """
  --- Day 18: Boiling Boulders ---
  https://adventofcode.com/2022/day/18
  """

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce({MapSet.new(), :infinity, 0}, fn s, {points, min, max} ->
      coords = s |> String.split(",") |> Enum.map(&String.to_integer/1)
      min = min(min, Enum.min(coords))
      max = max(max, Enum.max(coords))
      {MapSet.put(points, List.to_tuple(coords)), min, max}
    end)
  end

  def neighbors({x, y, z}) do
    [
      {1, 0, 0},
      {-1, 0, 0},
      {0, 1, 0},
      {0, -1, 0},
      {0, 0, 1},
      {0, 0, -1}
    ]
    |> Enum.map(fn {dx, dy, dz} -> {x + dx, y + dy, z + dz} end)
    |> MapSet.new()
  end

  def bounds_check_fn(min, max) do
    fn {x, y, z} -> [x, y, z] |> Enum.any?(fn c -> c < min - 1 or c > max + 1 end) end
  end

  # find the points that are outside the droplet with bfs.
  def outside_points(_cubes, [], points, _out_of_bounds?), do: points

  def outside_points(cubes, [point | queue], points, out_of_bounds?) do
    points = MapSet.put(points, point)

    next =
      point
      |> neighbors()
      |> MapSet.reject(&(&1 in queue))
      |> MapSet.reject(out_of_bounds?)
      |> MapSet.difference(points)
      |> MapSet.difference(cubes)
      |> Enum.to_list()

    outside_points(cubes, queue ++ next, points, out_of_bounds?)
  end

  def part1(input) do
    {cubes, _, _} = parse_input(input)

    # the neighbors of cubes that are not also cubes are empty spaces
    # corresponding to the open surfaces.
    for(cube <- cubes, neighbor <- neighbors(cube), do: neighbor)
    |> Enum.reject(&MapSet.member?(cubes, &1))
    |> Enum.count()
  end

  def part2(input) do
    {cubes, min_coord, max_coord} = parse_input(input)
    out_of_bounds? = bounds_check_fn(min_coord, max_coord)
    start_point = Stream.duplicate(min_coord, 3) |> Enum.to_list() |> List.to_tuple()
    outside_points = outside_points(cubes, [start_point], MapSet.new(), out_of_bounds?)

    # neighbors of cubes that were found to be outside the droplet
    for(cube <- cubes, neighbor <- neighbors(cube), do: neighbor)
    |> Enum.filter(&MapSet.member?(outside_points, &1))
    |> Enum.count()
  end
end
