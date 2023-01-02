defmodule AdventOfCode.Year2022.Day25Test do
  use ExUnit.Case

  import AdventOfCode.Year2022.Day25

  @input """
  1=-0-2
  12111
  2=0=
  21
  2=01
  111
  20012
  112
  1=-1=
  1-12
  12
  1=
  122
  """

  test "snafu_to_integer" do
    assert @input |> String.split("\n") |> Enum.map(&snafu_to_integer/1) |> Enum.sum() == 4890
    assert integer_to_snafu(4890) == "2=-1=0"
  end
end
