defmodule AdventOfCode.Year2015.Day02Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day02

  @part1_input %{
    "2x3x4" => 58,
    "1x1x10" => 43
  }

  @part2_input %{
    "2x3x4" => 34,
    "1x1x10" => 14
  }

  test "part1" do
    for {input, result} <- Map.to_list(@part1_input) do
      assert part1(input) == result
    end
  end

  test "part2" do
    for {input, result} <- Map.to_list(@part2_input) do
      assert part2(input) == result
    end
  end
end
