defmodule AdventOfCode.Year2015.Day11 do
  @moduledoc """
  --- Day 11: Corporate Policy ---
  https://adventofcode.com/2015/day/11
  """

  def increasing?(<<a::8, b::8, c::8, _rest::binary>>) when c - 1 == b and b - 1 == a, do: true
  def increasing?(<<_a::8, b::8, c::8, rest::binary>>), do: increasing?(<<b, c, rest::binary>>)
  def increasing?(_), do: false

  def exclude_iol?(s), do: ["i", "o", "l"] |> Enum.all?(&(not String.contains?(s, &1)))

  def two_pairs?(s, acc \\ 0)

  def two_pairs?(<<a::8, b::8, _rest::binary>>, 1) when a == b, do: true
  def two_pairs?(<<a::8, b::8, rest::binary>>, 0) when a == b, do: two_pairs?(rest, 1)
  def two_pairs?(<<_a::8, b::8, rest::binary>>, acc), do: two_pairs?(<<b, rest::binary>>, acc)
  def two_pairs?(_, _), do: false

  def valid?(s), do: increasing?(s) and exclude_iol?(s) and two_pairs?(s)

  def increment(s), do: s |> String.reverse() |> increment_rev() |> String.reverse()

  def increment_rev(<<"z", rest::binary>>), do: <<"a", increment_rev(rest)::binary>>

  def increment_rev(<<c::8, rest::binary>>), do: <<c + 1, rest::binary>>
  def increment_rev(<<>>), do: "a"

  def next_password(s) do
    s
    |> increment()
    |> Stream.iterate(&increment/1)
    |> Stream.drop_while(&(not valid?(&1)))
    |> Enum.take(1)
    |> hd()
  end

  def part1(input) do
    input
    |> String.trim()
    |> next_password()
  end

  def part2(input) do
    input
    |> String.trim()
    |> next_password()
    |> next_password()
  end
end
