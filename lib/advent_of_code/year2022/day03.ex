defmodule AdventOfCode.Year2022.Day03 do
  @moduledoc """
  --- Day 3: Rucksack Reorganization ---
  https://adventofcode.com/2022/day/3
  """

  @doc """
  Split the string in half.
  """
  def halves(s) do
    midpoint = s |> String.length() |> div(2)

    s
    |> String.split_at(midpoint)
    |> Tuple.to_list()
  end

  @doc """
  Make a MapSet of characters in a string.
  """
  def to_set(s), do: s |> String.codepoints() |> MapSet.new()

  @doc """
  Find an item that all the elements of the list have in common.
  """
  def intersection_all([first_ruck | rest]) do
    rest
    |> Enum.reduce(to_set(first_ruck), fn ruck, acc ->
      MapSet.intersection(acc, to_set(ruck))
    end)
    |> MapSet.to_list()
    |> hd()
  end

  @doc """
  Calculate the item priority.

  | range | priority | ASCII  |
  |-------|----------|--------|
  | a-z   | 1-26     | 97-122 |
  | A-Z   | 27-52    | 65-90  |
  """
  def priority(<<c>>) when c > 96, do: c - 96
  def priority(<<c>>), do: c - 38

  def part1(input) do
    input
    |> String.split()
    |> Enum.map(fn rucksack ->
      rucksack
      |> halves()
      |> intersection_all()
      |> priority()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split()
    |> Enum.chunk_every(3)
    |> Enum.map(fn group ->
      group
      |> intersection_all()
      |> priority()
    end)
    |> Enum.sum()
  end
end
