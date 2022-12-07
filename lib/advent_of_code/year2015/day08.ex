defmodule AdventOfCode.Year2015.Day08 do
  @moduledoc """
  --- Day 8: Matchsticks ---
  https://adventofcode.com/2015/day/8
  """

  def literal_length(s), do: String.length(s)

  def encoded_literal_length(s), do: inspect(s) |> String.length()

  def memory_length(s) do
    s
    |> Code.eval_string()
    |> elem(0)
    |> String.length()
  end

  def diff_literal_and_encoded(s), do: literal_length(s) - memory_length(s)

  def diff_encoded_literal_and_literal(s), do: encoded_literal_length(s) - literal_length(s)

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&diff_literal_and_encoded/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&diff_encoded_literal_and_literal/1)
    |> Enum.sum()
  end
end
