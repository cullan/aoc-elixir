defmodule AdventOfCode.Year2022.Day02 do
  @moduledoc """
  --- Day 2: Rock Paper Scissors ---
  https://adventofcode.com/2022/day/2
  """

  @shapes %{
    "A" => :rock,
    "X" => :rock,
    "B" => :paper,
    "Y" => :paper,
    "C" => :scissors,
    "Z" => :scissors
  }
  @shapes_part2 %{
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors,
    "X" => :lose,
    "Y" => :draw,
    "Z" => :win
  }
  @win_shape %{
    rock: :paper,
    paper: :scissors,
    scissors: :rock
  }
  @lose_shape Map.new(@win_shape, fn {key, val} -> {val, key} end)
  @shape_score %{
    rock: 1,
    paper: 2,
    scissors: 3
  }
  @lose 0
  @draw 3
  @win 6

  def score([opponent, me]) do
    shape_score = Map.get(@shape_score, me)

    result_score =
      cond do
        opponent == me -> @draw
        Map.get(@win_shape, opponent) == me -> @win
        true -> @lose
      end

    shape_score + result_score
  end

  def parse_input(input, shapes) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn round -> round |> String.split() |> Enum.map(&Map.get(shapes, &1)) end)
  end

  def choose([opponent, result]) do
    case {opponent, result} do
      {x, :draw} -> [x, x]
      {x, :win} -> [x, Map.get(@win_shape, x)]
      {x, :lose} -> [x, Map.get(@lose_shape, x)]
    end
  end

  def part1(input) do
    input
    |> parse_input(@shapes)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input(@shapes_part2)
    |> Enum.map(fn round -> round |> choose() |> score() end)
    |> Enum.sum()
  end
end
