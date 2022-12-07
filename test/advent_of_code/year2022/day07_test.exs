defmodule AdventOfCode.Year2022.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day07

  @input """
  $ cd /
  $ ls
  dir a
  14848514 b.txt
  8504156 c.dat
  dir d
  $ cd a
  $ ls
  dir e
  29116 f
  2557 g
  62596 h.lst
  $ cd e
  $ ls
  584 i
  $ cd ..
  $ cd ..
  $ cd d
  $ ls
  dir e
  4060174 j
  8033020 d.log
  5626152 d.ext
  7214296 k
  """

  @part1_expected_results [
    {@input, 95437}
  ]

  @part2_expected_results [
    {@input, 24933642}
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
