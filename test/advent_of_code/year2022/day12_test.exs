defmodule AdventOfCode.Year2022.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day12

  @input """
  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
  """

  @part1_expected_results [
    {@input, 31}
  ]

  @part2_expected_results [
    {@input, 29}
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
