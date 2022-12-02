defmodule AdventOfCode.Year2022.Day02Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day02

  @input """
  A Y
  B X
  C Z
  """

  test "part1" do
    assert part1(@input) == 15
  end

  test "part2" do
    assert part2(@input) == 12
  end
end
