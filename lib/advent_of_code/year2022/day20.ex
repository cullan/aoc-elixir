defmodule AdventOfCode.Year2022.Day20 do
  @moduledoc """
  --- Day 20: Grove Positioning System ---
  https://adventofcode.com/2022/day/20
  """
  alias AdventOfCode.CircleList

  import AdventOfCode.CircleList,
    only: [value: 1, seek: 2, insert: 2, pop: 1, reset: 1, seek_while: 2]

  def circle(input, key \\ 1) do
    input
    |> String.split()
    |> Enum.map(&(String.to_integer(&1) * key))
    |> Stream.with_index()
    |> CircleList.new()
  end

  def mod(0, _), do: 0
  def mod(n, size) when n > 0, do: rem(n, size - 1)
  def mod(n, size) when n < 0, do: -rem(-n, size - 1)

  def mix(circle) do
    size = CircleList.length(circle)

    {circle, 0}
    |> Stream.iterate(&mix_step(&1, size))
    |> Stream.chunk_every(2, 1)
    |> Stream.drop_while(fn
      [_, nil] -> false
      _ -> true
    end)
    |> Enum.take(1)
    |> hd()
    |> hd()
    |> elem(0)
  end

  def mix_step({circle, index}, size) do
    circle =
      circle
      |> reset()
      |> seek_while(fn
        {_item, ^index} -> false
        _ -> true
      end)

    if circle do
      {{n, _}, circle} = pop(circle)

      circle =
        circle
        |> seek(mod(n, size))
        |> insert({n, index})

      {circle, index + 1}
    end
  end

  def grove_coordinates(circle) do
    circle = circle |> seek_while(fn {item, _} -> item != 0 end)

    [1_000, 2_000, 3_000]
    |> Enum.map(&(circle |> seek(&1) |> value() |> elem(0)))
    |> Enum.sum()
  end

  def part1(input) do
    input
    |> circle()
    |> mix()
    |> grove_coordinates()
  end

  def part2(input) do
    input
    |> circle(811_589_153)
    |> Stream.iterate(&mix/1)
    |> Stream.drop(10)
    |> Enum.take(1)
    |> hd()
    |> grove_coordinates()
  end
end
