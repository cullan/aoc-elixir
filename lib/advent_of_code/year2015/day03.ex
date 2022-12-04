defmodule AdventOfCode.Year2015.Day03 do
  @moduledoc """
  --- Day 3: Perfectly Spherical Houses in a Vacuum ---
  https://adventofcode.com/2015/day/3
  """

  def moves(input), do: input |> String.codepoints()

  def move({x, y}, "^"), do: {x, y + 1}
  def move({x, y}, "v"), do: {x, y - 1}
  def move({x, y}, ">"), do: {x + 1, y}
  def move({x, y}, "<"), do: {x - 1, y}

  def locations_visited(moves) do
    moves
    |> Enum.reduce({{0, 0}, MapSet.new([{0, 0}])}, fn direction, {location, acc} ->
      new_location = move(location, direction)
      {new_location, MapSet.put(acc, new_location)}
    end)
    |> elem(1)
  end

  def part1(input) do
    input
    |> moves()
    |> locations_visited()
    |> MapSet.size()
  end

  def part2(input) do
    moves = moves(input)
    santa_moves = moves |> Enum.take_every(2)
    robot_moves = moves |> tl() |> Enum.take_every(2)

    visited =
      MapSet.union(
        locations_visited(santa_moves),
        locations_visited(robot_moves)
      )

    MapSet.size(visited)
  end
end
