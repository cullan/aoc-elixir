defmodule AdventOfCode.Year2022.Day20Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day20

  @input """
  1
  2
  -3
  3
  -2
  0
  4
  """

  @part1_expected_results [
    {@input, 3}
  ]

  @part2_expected_results [
    {@input, 1_623_178_306}
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
