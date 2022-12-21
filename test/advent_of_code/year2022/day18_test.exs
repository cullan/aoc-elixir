defmodule AdventOfCode.Year2022.Day18Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day18

  @input """
  2,2,2
  1,2,2
  3,2,2
  2,1,2
  2,3,2
  2,2,1
  2,2,3
  2,2,4
  2,2,6
  1,2,5
  3,2,5
  2,1,5
  2,3,5
  """

  @part1_expected_results [
    {@input, 64}
  ]

  @part2_expected_results [
    {@input, 58}
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
