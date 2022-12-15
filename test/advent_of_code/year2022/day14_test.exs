defmodule AdventOfCode.Year2022.Day14Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day14

  @input """
  498,4 -> 498,6 -> 496,6
  503,4 -> 502,4 -> 502,9 -> 494,9
  """

  @part1_expected_results [
    {@input, 24}
  ]

  @part2_expected_results [
    {@input, 93}
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
