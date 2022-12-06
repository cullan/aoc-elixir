defmodule AdventOfCode.Year2022.Day06 do
  @moduledoc """
  --- Day 6: Tuning Trouble ---
  https://adventofcode.com/2022/day/6
  """

  def find_marker(s, window_size) do
    s
    |> String.codepoints()
    |> Stream.chunk_every(window_size, 1)
    |> Enum.reduce_while(window_size, fn chunk, acc ->
      if length(chunk) == chunk |> MapSet.new() |> MapSet.size() do
        {:halt, acc}
      else
        {:cont, acc + 1}
      end
    end)
  end

  def find_start_of_packet_marker(s), do: find_marker(s, 4)
  def find_start_of_message_marker(s), do: find_marker(s, 14)

  def part1(input) do
    find_start_of_packet_marker(input)
  end

  def part2(input) do
    find_start_of_message_marker(input)
  end
end
