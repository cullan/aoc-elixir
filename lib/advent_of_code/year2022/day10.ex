defmodule AdventOfCode.Year2022.Day10 do
  @moduledoc """
  --- Day 10: Cathode-Ray Tube ---
  https://adventofcode.com/2022/day/10
  """

  alias AdventOfCode.OCR

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.flat_map(fn instruction ->
      cond do
        instruction == "noop" ->
          [:noop]

        String.starts_with?(instruction, "addx ") ->
          [_, n] = String.split(instruction)
          # replace addx n with noop, addx n to simplify executing later
          [:noop, {:addx, String.to_integer(n)}]
      end
    end)
  end

  defp execute(:noop, acc), do: {[acc], acc}
  defp execute({:addx, n}, acc), do: {[acc + n], acc + n}

  # Stream the values resulting from executing the instructions along with the cycle.
  # eg: [{1, 1}, {1, 2}, {16, 3}] means value was 1 during cycles 1 and 2 and 16 during cycle 3
  defp values_during_cycles(instructions) do
    stream =
      instructions
      |> Stream.transform(1, &execute/2)
      |> Stream.with_index(2)

    Stream.concat([{1, 1}], stream)
  end

  # Make a stream of the signal strength during the given cycles using the instruction list.
  defp signal_strength_during_cycles(vals, cycles) do
    vals
    |> Stream.filter(fn {_val, i} -> i in cycles end)
    |> Stream.map(&signal_strength/1)
    |> Enum.to_list()
  end

  defp signal_strength({val, cycle}), do: val * cycle

  defp visible?({val, cycle}, row) do
    current = cycle - row * 40
    current >= val and current < val + 3
  end

  defp pixels({values, row}) do
    values
    |> Stream.map(fn cycle_val -> if visible?(cycle_val, row), do: "#", else: "." end)
  end

  def screen_output(input) do
    input
    |> parse_input()
    |> values_during_cycles()
    |> Stream.chunk_every(40, 40, :discard)
    |> Stream.with_index(0)
    |> Stream.map(&pixels/1)
    |> Stream.map(&Enum.join(&1, ""))
  end

  def part1(input) do
    input
    |> parse_input()
    |> values_during_cycles()
    |> signal_strength_during_cycles([20, 60, 100, 140, 180, 220])
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> screen_output()
    |> OCR.read_screen()
  end
end
