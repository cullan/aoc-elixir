defmodule AdventOfCode.Year2022.Day01 do
  @moduledoc """
  --- Day 1: Calorie Counting ---
  https://adventofcode.com/2022/day/1
  """

  def part1(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&(&1 |> String.split() |> to_ints() |> Enum.sum()))
    |> Enum.max()
  end

  def part2(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&(&1 |> String.split() |> to_ints() |> Enum.sum()))
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp to_ints(xs), do: Enum.map(xs, &String.to_integer/1)
end
