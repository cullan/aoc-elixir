defmodule AdventOfCode.Year2015.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day12

  @part1_expected_results [
    {~S([1,2,3]), 6},
    {~S({"a":2,"b":4}), 6},
    {~S([[[3]]]), 3},
    {~S({"a":{"b":4},"c":-1}), 3},
    {~S({"a":[-1,1]}), 0},
    {~S([-1,{"a":1}]), 0},
    {~S([]), 0},
    {~S({}), 0}
  ]

  @part2_expected_results [
    {~S([1,2,3]), 6},
    {~S([1,{"c":"red","b":2},3]), 4},
    {~S({"d":"red","e":[1,2,3,4],"f":5}), 0},
    {~S([1,"red",5]), 6}
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
