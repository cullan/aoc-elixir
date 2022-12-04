defmodule AdventOfCode.Year2015.Day04Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day04

  @part1_input %{
    "abcdef" => 609_043,
    "pqrstuv" => 1_048_970
  }

  test "part1" do
    for {input, result} <- @part1_input do
      assert part1(input) == result
    end
  end
end
