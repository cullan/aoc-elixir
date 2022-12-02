defmodule Mix.Tasks.Aoc.Prepare do
  @shortdoc "Adds source and test files for a day's puzzle."
  use Mix.Task

  import AdventOfCode, only: [zero_pad: 1]

  defp prepare(day, year) do
    # need to run the app to load the config that has the session token
    Mix.Task.run("app.start")
    IO.puts("preparing to solve #{year}/#{day}.")
    description = AdventOfCode.fetch!(:description, day, year)

    lib_path = Path.join([file_path("lib", year), "day#{zero_pad(day)}.ex"])
    lib_path |> Path.dirname() |> File.mkdir_p()
    File.write(lib_path, source_template(day, year, description))

    test_path = Path.join([file_path("test", year), "day#{zero_pad(day)}_test.exs"])
    test_path |> Path.dirname() |> File.mkdir_p()
    File.write(test_path, test_template(day, year))
  end

  defp file_path(type, year), do: Path.join([File.cwd!(), type, "advent_of_code", "year#{year}"])

  defp source_template(day, year, title) do
    """
    defmodule AdventOfCode.Year#{year}.Day#{zero_pad(day)} do
      @moduledoc \"\"\"
      #{title}
      https://adventofcode.com/#{year}/day/#{day}
      \"\"\"

      def part1(_input) do
      end

      def part2(_input) do
      end
    end
    """
  end

  defp test_template(day, year) do
    """
    defmodule AdventOfCode.Year#{year}.Day#{zero_pad(day)}Test do
      use ExUnit.Case

      import AdventOfCode.Year#{year}.Day#{zero_pad(day)}

      @input \"\"\"
      \"\"\"

      @tag :skip
      test "part1" do
        assert part1(@input) == :fixme
      end

      @tag :skip
      test "part2" do
        assert part2(@input) == :fixme
      end
    end
    """
  end

  def run([day]), do: prepare(day, DateTime.utc_now().year)
  def run([day, year]), do: prepare(day, year)
end
