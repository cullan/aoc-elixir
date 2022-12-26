defmodule AdventOfCode.Year2022.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day16

  @input """
  Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
  Valve BB has flow rate=13; tunnels lead to valves CC, AA
  Valve CC has flow rate=2; tunnels lead to valves DD, BB
  Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
  Valve EE has flow rate=3; tunnels lead to valves FF, DD
  Valve FF has flow rate=0; tunnels lead to valves EE, GG
  Valve GG has flow rate=0; tunnels lead to valves FF, HH
  Valve HH has flow rate=22; tunnel leads to valve GG
  Valve II has flow rate=0; tunnels lead to valves AA, JJ
  Valve JJ has flow rate=21; tunnel leads to valve II
  """

  @part1_expected_results [
    {@input, 1651}
  ]

  @part2_expected_results [
    {@input, 1707}
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
