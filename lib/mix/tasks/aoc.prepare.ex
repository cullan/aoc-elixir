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
    test_path = Path.join([file_path("test", year), "day#{zero_pad(day)}_test.exs"])

    # create directories as needed
    lib_path |> Path.dirname() |> File.mkdir_p()
    test_path |> Path.dirname() |> File.mkdir_p()

    # create files using templates if they are not already there
    unless File.exists?(lib_path),
      do: File.write(lib_path, source_template(day, year, description))

    unless File.exists?(test_path),
      do: File.write(test_path, test_template(day, year))
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

      @part1_input %{
        "" => nil
      }

      @part2_input %{
        "" => nil
      }

      @tag :skip
      test "part1" do
        for {input, result} <- @part1_input do
          assert part1(input) == result
        end
      end

      @tag :skip
      test "part2" do
        for {input, result} <- @part2_input do
          assert part2(input) == result
        end
      end
    end
    """
  end

  def run([day]), do: prepare(day, DateTime.utc_now().year)
  def run([day, year]), do: prepare(day, year)
end
