defmodule AdventOfCode.Year2015.Day08Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day08

  @input """
  ""
  "abc"
  "aaa\\"aaa"
  "\\x27"
  """

  @part1_expected_results [
    {@input, 12}
  ]

  @part2_expected_results [
    {@input, 19}
  ]

  test "part1" do
    for {input, result} <- @part1_expected_results do
      assert part1(input) == result
    end
  end

  test "part2" do
    for {input, result} <- @part2_expected_results do
      assert part2(input) == result
    end
  end
end
