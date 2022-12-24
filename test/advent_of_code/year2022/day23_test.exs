defmodule AdventOfCode.Year2022.Day23Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day23

  @input """
  ....#..
  ..###.#
  #...#.#
  .#...##
  #.###..
  ##.#.##
  .#..#..
  """

  @part1_expected_results [
    {@input, 110}
  ]

  @part2_expected_results [
    {@input, 20}
  ]

  test "part1" do
    for {input, result} <- @part1_expected_results do
      assert part1(input) == result
    end
  end

  @tag :skip
  test "part2" do
    for {input, result} <- @part2_expected_results do
      assert part2(input) == result
    end
  end
end
