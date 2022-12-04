defmodule AdventOfCode.Year2022.Day04 do
  @moduledoc """
  --- Day 4: Camp Cleanup ---
  https://adventofcode.com/2022/day/4
  """

  def section_assignment_pairs(input) do
    input
    |> String.split()
    |> Enum.map(fn pair ->
      pair
      |> String.split(",")
      |> Enum.map(&section_assignment_range/1)
    end)
  end

  def section_assignment_range(s), do: s |> String.split("-") |> Enum.map(&String.to_integer/1)

  def fully_overlaps?([[elf1_begin, elf1_end], [elf2_begin, elf2_end]]) do
    cond do
      elf1_begin >= elf2_begin and elf1_end <= elf2_end -> true
      elf2_begin >= elf1_begin and elf2_end <= elf1_end -> true
      true -> false
    end
  end

  def overlaps?([[elf1_begin, elf1_end], [elf2_begin, elf2_end]]) do
    not Range.disjoint?(
      Range.new(elf1_begin, elf1_end),
      Range.new(elf2_begin, elf2_end)
    )
  end

  def part1(input) do
    input
    |> section_assignment_pairs()
    |> Enum.count(&fully_overlaps?/1)
  end

  def part2(input) do
    input
    |> section_assignment_pairs()
    |> Enum.count(&overlaps?/1)
  end
end
