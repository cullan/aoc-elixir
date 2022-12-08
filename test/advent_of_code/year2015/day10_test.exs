defmodule AdventOfCode.Year2015.Day10Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day10

  @part1_expected_results [
    {"1", "11"},
    {"11", "21"},
    {"21", "1211"},
    {"1211", "111221"},
    {"111221", "312211"}
  ]

  @part2_expected_results [
    {@input, :fixme}
  ]

  test "part1" do
    for {input, result} <- @part1_expected_results do
      assert look_and_say(input) == result
    end
  end

  @tag :skip
  test "part2" do
    for {input, result} <- @part2_expected_results do
      assert part2(input) == result
    end
  end
end
