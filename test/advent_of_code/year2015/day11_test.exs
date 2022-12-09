defmodule AdventOfCode.Year2015.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day11

  @part1_expected_results [
    {"hijklmmn", false},
    {"abbceffg", false},
    {"abbcegjk", false},
    {"abcdffaa", true},
    {"ghjaabcc", true}
  ]

  test "part1" do
    for {input, result} <- @part1_expected_results do
      assert valid?(input) == result
    end
  end
end
