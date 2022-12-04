defmodule AdventOfCode.Year2015.Day06 do
  @moduledoc """
  --- Day 6: Probably a Fire Hazard ---
  https://adventofcode.com/2015/day/6
  """

  def parse("turn on " <> rest), do: parse(:on, rest)
  def parse("turn off " <> rest), do: parse(:off, rest)
  def parse("toggle " <> rest), do: parse(:toggle, rest)

  def parse(action, s) do
    [corner1, corner2] = corners(s)
    {action, corner1, corner2}
  end

  def parse_input(input), do: input |> String.trim() |> String.split("\n") |> Enum.map(&parse/1)

  def corners(s) do
    s
    |> String.split(" through ")
    |> Enum.map(fn p ->
      p
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  def points({x1, y1}, {x2, y2}),
    do: for(x <- Range.new(x1, x2), y <- Range.new(y1, y2), do: {x, y})

  def update_part1(:toggle, lights, point), do: Map.update(lights, point, true, &(not &1))
  def update_part1(:on, lights, point), do: Map.put(lights, point, true)
  def update_part1(:off, lights, point), do: Map.put(lights, point, false)

  def update_part2(:toggle, lights, point), do: Map.update(lights, point, 2, &(&1 + 2))
  def update_part2(:on, lights, point), do: Map.update(lights, point, 1, &(&1 + 1))
  def update_part2(:off, lights, point), do: Map.update(lights, point, 0, &max(0, &1 - 1))

  def change_lights(update_fn, lights, action, points) do
    points
    |> Enum.reduce(lights, fn point, acc ->
      update_fn.(action, acc, point)
    end)
  end

  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce(%{}, fn {action, p1, p2}, acc ->
      change_lights(&update_part1/3, acc, action, points(p1, p2))
    end)
    |> Map.values()
    |> Enum.count(& &1)
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.reduce(%{}, fn {action, p1, p2}, acc ->
      change_lights(&update_part2/3, acc, action, points(p1, p2))
    end)
    |> Map.values()
    |> Enum.sum()
  end
end
