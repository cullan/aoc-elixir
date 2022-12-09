defmodule AdventOfCode.Year2015.Day12 do
  @moduledoc """
  --- Day 12: JSAbacusFramework.io ---
  https://adventofcode.com/2015/day/12
  """

  def contains_red?(%{} = obj), do: obj |> Map.values() |> Enum.any?(&(&1 == "red"))

  def sum_numbers(s) when is_bitstring(s) do
    Regex.scan(~r/(-?\d+)/, s)
    |> Enum.map(fn [_, digit] -> String.to_integer(digit) end)
    |> Enum.sum()
  end

  def sum_numbers(%{} = obj) do
    if contains_red?(obj) do
      0
    else
      obj
      |> Map.values()
      |> Enum.filter(&is_integer/1)
      |> Enum.sum()
    end
  end

  def sum_numbers(lst) when is_list(lst) do
    lst
    |> Enum.filter(&is_integer/1)
    |> Enum.sum()
  end

  def container?(a) when is_list(a) or is_map(a), do: true
  def container?(_), do: false

  def walk(container, function), do: walk_helper([container], function, [])

  def walk_helper([], _, acc), do: acc

  def walk_helper([%{} = current | stack], f, acc) do
    if contains_red?(current) do
      walk_helper(stack, f, acc)
    else
      # push the children on the stack
      stack =
        current |> Map.values() |> Enum.filter(&container?/1) |> Enum.reduce(stack, &[&1 | &2])

      # store the result of calling the function in the accumulator
      walk_helper(stack, f, [f.(current) | acc])
    end
  end

  def walk_helper([current | stack], f, acc) when is_list(current) do
    stack = current |> Enum.filter(&container?/1) |> Enum.reduce(stack, &[&1 | &2])
    walk_helper(stack, f, [f.(current) | acc])
  end

  def part1(input) do
    input
    |> sum_numbers()
  end

  def part2(input) do
    input
    |> Jason.decode!()
    |> walk(&sum_numbers/1)
    |> Enum.sum()
  end
end
