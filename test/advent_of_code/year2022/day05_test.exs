defmodule AdventOfCode.Year2022.Day05Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day05

  # goofiness to prevent emacs from destroying the significant trailing whitespace
  @input "    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 \n" <>
           """

           move 1 from 2 to 1
           move 3 from 1 to 3
           move 2 from 2 to 1
           move 1 from 1 to 2
           """

  @part1_input [
    {@input, "CMZ"}
  ]

  @part2_input [
    {@input, "MCD"}
  ]

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
