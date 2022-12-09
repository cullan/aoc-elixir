defmodule AdventOfCode.Year2022.Day08Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day08

  @input """
  30373
  25512
  65332
  33549
  35390
  """

  @part1_expected_results [
    {@input, 21}
  ]

  @part2_expected_results [
    {@input, 8}
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
