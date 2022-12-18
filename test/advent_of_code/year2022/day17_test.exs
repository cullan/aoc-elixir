defmodule AdventOfCode.Year2022.Day17Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day17

  @input ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

  @part1_expected_results [
    {@input, 3068}
  ]

  @part2_expected_results [
    {@input, 1_514_285_714_288}
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
