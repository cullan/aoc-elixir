defmodule AdventOfCode.Year2015.Day01 do
  @moduledoc """
  --- Day 1: Not Quite Lisp ---
  https://adventofcode.com/2015/day/1
  """

  @doc """
  Calculate the final floor reached after starting at floor zero and following the instructions.

  instructions is a string made up of ")" and "(".
  "(" means go up a floor
  ")" means go down a floor
  """
  def final_floor(instructions) do
    instructions
    |> String.codepoints()
    |> Enum.reduce(0, &move/2)
  end

  @doc """
  Move up or down a floor based on the instruction.
  """
  def move("(", floor), do: floor + 1
  def move(")", floor), do: floor - 1

  @doc """
  Calculate the next floor based on the instruction and increment the number of moves taken so far.
  Return the number of moves when the basement is reached.
  """
  def move_until_basement(instruction, {current_floor, moves}) do
    next_floor = move(instruction, current_floor)

    if next_floor == -1 do
      {:halt, moves + 1}
    else
      {:cont, {next_floor, moves + 1}}
    end
  end

  @doc """
  Calculate the number of moves needed to reach the basement following the instructions.
  """
  def moves_to_basement(instructions) do
    instructions
    |> String.codepoints()
    |> Enum.reduce_while({0, 0}, &move_until_basement/2)
  end

  def part1(input) do
    final_floor(input)
  end

  def part2(input) do
    moves_to_basement(input)
  end
end
