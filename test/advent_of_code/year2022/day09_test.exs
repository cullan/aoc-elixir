defmodule AdventOfCode.Year2022.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day09

  @input """
  R 4
  U 4
  L 3
  D 1
  R 4
  D 1
  L 5
  R 2
  """

  @part1_expected_results [
    {@input, 13}
  ]

  @part2_expected_results [
    {@input, 1},
    {"""
     R 5
     U 8
     L 8
     D 3
     R 17
     D 10
     L 25
     U 20
     """, 36}
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
