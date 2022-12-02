defmodule AdventOfCode.Year2022.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day01

  @input """
  1000
  2000
  3000

  4000

  5000
  6000

  7000
  8000
  9000

  10000
  """

  test "part1" do
    assert part1(@input) == 24000
  end

  test "part2" do
    assert part2(@input) == 45000
  end
end
