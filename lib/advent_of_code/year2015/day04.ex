defmodule AdventOfCode.Year2015.Day04 do
  @moduledoc """
  --- Day 4: The Ideal Stocking Stuffer ---
  https://adventofcode.com/2015/day/4
  """

  def md5(s), do: :crypto.hash(:md5, s) |> Base.encode16()

  def match5?("00000" <> _rest), do: true
  def match5?(_), do: false

  def match6?("000000" <> _rest), do: true
  def match6?(_), do: false

  def ns(), do: Stream.iterate(0, &(&1 + 1))

  def hash_number(s, match?) do
    ns()
    |> Stream.filter(fn n ->
      "#{s}#{n}"
      |> md5()
      |> match?.()
    end)
    |> Enum.take(1)
    |> hd()
  end

  def part1(input) do
    input
    |> String.trim()
    |> hash_number(&match5?/1)
  end

  def part2(input) do
    input
    |> String.trim()
    |> hash_number(&match6?/1)
  end
end
