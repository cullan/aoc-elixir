defmodule AdventOfCode.Year2015.Day05 do
  @moduledoc """
  --- Day 5: Doesn't He Have Intern-Elves For This? ---
  https://adventofcode.com/2015/day/5
  """

  def vowel?(c) when c in ["a", "e", "i", "o", "u"], do: true
  def vowel?(_), do: false

  def count_vowels(s), do: s |> String.codepoints() |> Enum.count(&vowel?/1)

  def contains_naughty_substring?(s) do
    cond do
      String.contains?(s, "ab") -> true
      String.contains?(s, "cd") -> true
      String.contains?(s, "pq") -> true
      String.contains?(s, "xy") -> true
      true -> false
    end
  end

  def repeats_char?(s), do: Regex.match?(~r/(.)\1/, s)

  def nice_part1?(s) do
    count_vowels(s) >= 3 and repeats_char?(s) and not contains_naughty_substring?(s)
  end

  def repeats_repeat?(s), do: Regex.match?(~r/(..).*\1/, s)

  def repeats_one_between?(s), do: Regex.match?(~r/(.).\1/, s)

  def nice_part2?(s), do: repeats_repeat?(s) and repeats_one_between?(s)

  def part1(input) do
    input
    |> String.split()
    |> Enum.count(&nice_part1?/1)
  end

  def part2(input) do
    input
    |> String.split()
    |> Enum.count(&nice_part2?/1)
  end
end
