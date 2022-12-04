defmodule AdventOfCode.Year2015.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day03

  @part1_input %{
    ">" => 2,
    "^>v<" => 4,
    "^v^v^v^v^v" => 2
  }

  @part2_input %{
    "^v" => 3,
    "^>v<" => 3,
    "^v^v^v^v^v" => 11
  }

  test "part1" do
    for {input, result} <- @part1_input do
      assert part1(input) == result
    end
  end

  test "part2" do
    for {input, result} <- @part2_input do
      assert part2(input) == result
    end
  end
end
