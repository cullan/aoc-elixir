defmodule AdventOfCode.Year2015.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day01

  @inputs %{
    "(())" => 0,
    "()()" => 0,
    "(((" => 3,
    "(()(()(" => 3,
    "))(((((" => 3,
    "())" => -1,
    "))(" => -1,
    ")))" => -3,
    ")())())" => -3
  }

  @part2_inputs %{
    ")" => 1,
    "()())" => 5
  }

  test "part1" do
    for {input, result} <- Map.to_list(@inputs) do
      assert part1(input) == result
    end
  end

  test "part2" do
    for {input, result} <- Map.to_list(@part2_inputs) do
      assert part2(input) == result
    end
  end
end
