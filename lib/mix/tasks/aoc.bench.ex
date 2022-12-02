defmodule Mix.Tasks.Aoc.Bench do
  @shortdoc "Benchmark the solutions to a day's puzzles."
  use Mix.Task

  alias AdventOfCode.Input

  def run([day]), do: run([day, DateTime.utc_now().year])

  def run([day, year]) do
    module = :"Elixir.AdventOfCode.Year#{year}.Day#{AdventOfCode.zero_pad(day)}"
    input = Input.get!(day, year)

    Benchee.run(%{
      "part1" => fn -> module.part1(input) end,
      "part2" => fn -> module.part2(input) end
    })
  end
end
