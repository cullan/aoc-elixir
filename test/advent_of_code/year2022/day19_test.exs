defmodule AdventOfCode.Year2022.Day19Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day19

  @input """
  Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
  Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
  """

  @part1_expected_results [
    {@input, 33}
  ]

  @part2_expected_results [
    {@input, :fixme}
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
