defmodule Mix.Tasks.Aoc.Run do
  @shortdoc "Calculate the solutions to a day's puzzles."
  use Mix.Task

  alias AdventOfCode.Input

  def run([day]), do: run([day, DateTime.utc_now().year])

  def run([day, year]) do
    Mix.Task.run("app.start")
    module = :"Elixir.AdventOfCode.Year#{year}.Day#{AdventOfCode.zero_pad(day)}"
    input = Input.get!(day, year)
    IO.puts("part 1: #{module.part1(input)}")
    IO.puts("part 2: #{module.part2(input)}")
  end
end
