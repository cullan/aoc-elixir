defmodule AdventOfCode.Year2022.Day13 do
  @moduledoc """
  --- Day 13: Distress Signal ---
  https://adventofcode.com/2022/day/13
  """

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Jason.decode!/1)
  end

  def compare([a, b]), do: compare(a, b)

  def compare([], []), do: nil

  def compare([], _), do: true

  def compare(_, []), do: false

  def compare([a | as], [b | bs]) when is_integer(a) and is_integer(b) do
    cond do
      a < b -> true
      a > b -> false
      a == b -> compare(as, bs)
    end
  end

  def compare([a | as], [b | bs]) when is_list(a) and is_list(b) do
    case compare(a, b) do
      nil -> compare(as, bs)
      result -> result
    end
  end

  def compare([a | as], [b | bs]), do: compare([List.wrap(a) | as], [List.wrap(b) | bs])

  def part1(input) do
    input
    |> parse_input()
    |> Enum.chunk_every(2)
    |> Stream.with_index(1)
    |> Enum.filter(&compare(elem(&1, 0)))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(input) do
    divider_packets = [[[2]], [[6]]]

    input
    |> parse_input()
    |> Stream.concat(divider_packets)
    |> Enum.sort(fn a, b -> compare(a, b) end)
    |> Stream.with_index(1)
    |> Enum.filter(&(elem(&1, 0) in divider_packets))
    |> Enum.map(&elem(&1, 1))
    |> Enum.product()
  end
end
