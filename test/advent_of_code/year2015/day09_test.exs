defmodule AdventOfCode.Year2015.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day09

  @input """
  London to Dublin = 464
  London to Belfast = 518
  Dublin to Belfast = 141
  """

  @part1_expected_results [
    {@input, 605}
  ]

  @part2_expected_results [
    {@input, 982}
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
