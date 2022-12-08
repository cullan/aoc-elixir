defmodule AdventOfCode.Year2015.Day10 do
  @moduledoc """
  --- Day 10: Elves Look, Elves Say ---
  https://adventofcode.com/2015/day/10
  """

  def look_and_say(binary, acc \\ [])

  def look_and_say(<<>>, acc) do
    acc
    |> Enum.reverse()
    |> Enum.map(fn {count, c} ->
      "#{count}#{<<c>>}"
    end)
    |> Enum.join()
  end

  def look_and_say(<<c::8, rest::binary>>, []), do: look_and_say(rest, [{1, c}])

  def look_and_say(<<c::8, rest::binary>>, [{count, char} = head | tail]) do
    if c == char do
      look_and_say(rest, [{count + 1, c} | tail])
    else
      look_and_say(rest, [{1, c} | [head | tail]])
    end
  end

  def repeat_look_and_say(s, times) do
    s
    |> String.trim()
    |> Stream.iterate(&look_and_say/1)
    |> Stream.drop(times)
    |> Enum.take(1)
    |> hd()
  end

  def part1(input) do
    input
    |> repeat_look_and_say(40)
    |> String.length()
  end

  def part2(input) do
    input
    |> repeat_look_and_say(50)
    |> String.length()
  end
end
