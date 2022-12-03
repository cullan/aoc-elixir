defmodule AdventOfCode.Year2022.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day03

  @input """
  vJrwpWtwJgWrhcsFMMfFFhFp
  jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
  PmmdzqPrVvPwwTWBwg
  wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
  ttgJtRGJQctTZtZT
  CrZsJsPPZsGzwwsLwLmpwMDw
  """

  test "part1" do
    assert part1(@input) == 157
  end

  test "part2" do
    assert part2(@input) == 70
  end
end
