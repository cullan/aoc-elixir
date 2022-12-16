defmodule AdventOfCode.Year2022.Day15Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day15

  @input """
  Sensor at x=2, y=18: closest beacon is at x=-2, y=15
  Sensor at x=9, y=16: closest beacon is at x=10, y=16
  Sensor at x=13, y=2: closest beacon is at x=15, y=3
  Sensor at x=12, y=14: closest beacon is at x=10, y=16
  Sensor at x=10, y=20: closest beacon is at x=10, y=16
  Sensor at x=14, y=17: closest beacon is at x=10, y=16
  Sensor at x=8, y=7: closest beacon is at x=2, y=10
  Sensor at x=2, y=0: closest beacon is at x=2, y=10
  Sensor at x=0, y=11: closest beacon is at x=2, y=10
  Sensor at x=20, y=14: closest beacon is at x=25, y=17
  Sensor at x=17, y=20: closest beacon is at x=21, y=22
  Sensor at x=16, y=7: closest beacon is at x=15, y=3
  Sensor at x=14, y=3: closest beacon is at x=15, y=3
  Sensor at x=20, y=1: closest beacon is at x=15, y=3
  """

  @part1_expected_results [
    {@input, 26}
  ]

  @part2_expected_results [
    {@input, 56_000_011}
  ]

  test "part1" do
    for {input, result} <- @part1_expected_results do
      assert part1(input, 10) == result
    end
  end

  test "part2" do
    for {input, result} <- @part2_expected_results do
      assert part2(input, 20) == result
    end
  end
end
