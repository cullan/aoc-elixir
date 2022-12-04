defmodule AdventOfCode.Year2015.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day06

  @part1_input %{
    """
    turn on 0,0 through 1,1
    turn off 0,0 through 0,1
    toggle 0,1 through 0,1
    """ => 3
  }

  @part2_input %{
    """
    toggle 0,0 through 999,999
    """ => 2_000_000
  }

  test "part1" do
    for {input, result} <- @part1_input do
      assert part1(input) == result
    end
  end

  test "part2" do
    for {input, result} <- @part2_input do
      assert part2(input) == result
    end
  end
end
