defmodule AdventOfCode.Year2022.Day22Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day22

  @input """
          ...#
          .#..
          #...
          ....
  ...#.......#
  ........#...
  ..#....#....
  ..........#.
          ...#....
          .....#..
          .#......
          ......#.

  10R5L5R10L4R5L5
  """

  @part1_expected_results [
    {@input, 6032}
  ]

  @part2_expected_results [
    {@input, 5031}
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
