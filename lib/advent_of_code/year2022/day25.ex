defmodule AdventOfCode.Year2022.Day25 do
  @moduledoc """
  --- Day 25: Full of Hot Air ---
  https://adventofcode.com/2022/day/25
  """

  @snafu_digit_base_10 %{
    "2" => 2,
    "1" => 1,
    "0" => 0,
    "-" => -1,
    "=" => -2
  }

  @base_10_snafu_digit %{
    0 => "=",
    1 => "-",
    2 => "0",
    3 => "1",
    4 => "2"
  }

  def snafu_to_integer(s) when is_binary(s) do
    digits = s |> String.codepoints() |> Enum.map(&Map.get(@snafu_digit_base_10, &1))
    snafu_to_integer(digits |> Enum.reverse(), 1, 0)
  end

  defp snafu_to_integer([], _, sum), do: sum

  defp snafu_to_integer([c | rest], power, sum) do
    snafu_to_integer(rest, power * 5, sum + c * power)
  end

  def integer_to_snafu(n), do: integer_to_snafu(n, [])

  defp integer_to_snafu(0, acc), do: acc |> Enum.join("")

  defp integer_to_snafu(n, acc) do
    {n, rem} = {div(n + 2, 5), rem(n + 2, 5)}
    integer_to_snafu(n, [Map.get(@base_10_snafu_digit, rem) | acc])
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&snafu_to_integer/1)
    |> Enum.sum()
    |> then(&integer_to_snafu(&1))
  end

  def part2(_input) do
  end
end
