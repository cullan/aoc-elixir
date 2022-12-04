defmodule AdventOfCode.Year2015.Day05Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day05

  @part1_input %{
    "ugknbfddgicrmopn" => 1,
    "aaa" => 1,
    "jchzalrnumimnmhp" => 0,
    "haegwjzuvuyypxyu" => 0,
    "dvszwmarrgswjxmb" => 0,
    """
    ugknbfddgicrmopn
    aaa
    jchzalrnumimnmhp
    haegwjzuvuyypxyu
    dvszwmarrgswjxmb
    """ => 2
  }

  @part2_input %{
    "qjhvhtzxzqqjkmpb" => 1,
    "xxyxx" => 1,
    "uurcxstgmygtbstg" => 0,
    "ieodomkazucvgmuy" => 0,
    """
    qjhvhtzxzqqjkmpb
    xxyxx
    uurcxstgmygtbstg
    ieodomkazucvgmuy
    """ => 2
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
