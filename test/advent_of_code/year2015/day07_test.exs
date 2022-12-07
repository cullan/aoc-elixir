defmodule AdventOfCode.Year2015.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Year2015.Day07

  @part1_input [
    {"""
     123 -> x
     456 -> y
     x AND y -> d
     x OR y -> e
     x LSHIFT 2 -> f
     y RSHIFT 2 -> g
     NOT x -> h
     NOT y -> i
     """,
     %{
       d: 72,
       e: 507,
       f: 492,
       g: 114,
       h: 65412,
       i: 65079,
       x: 123,
       y: 456
     }}
  ]

  test "part1" do
    for {input, result} <- @part1_input do
      assert input |> get_instructions() |> calculate_signals() == result
    end
  end
end
