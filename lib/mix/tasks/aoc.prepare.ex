defmodule Mix.Tasks.Aoc.Prepare do
  @shortdoc "Adds source and test files for a day's puzzle."
  use Mix.Task

  import AdventOfCode, only: [zero_pad: 1]

  defp prepare(day, year) do
    # need to run the app to load the config that has the session token
    Mix.Task.run("app.start")
    IO.puts("preparing to solve #{year}/#{day}.")

    create_lib(day, year)
    create_test(day, year)
  end

  defp create_lib(day, year) do
    path = Path.join([file_path("lib", year), "day#{zero_pad(day)}.ex"])

    unless File.exists?(path) do
      path |> Path.dirname() |> File.mkdir_p()
      title = AdventOfCode.fetch!(:title, day, year)
      File.write(path, source_template(day, year, title))
    end
  end

  defp create_test(day, year) do
    path = Path.join([file_path("test", year), "day#{zero_pad(day)}_test.exs"])

    unless File.exists?(path) do
      path |> Path.dirname() |> File.mkdir_p()
      File.write(path, test_template(day, year))
    end
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

      @input ""

      @part1_expected_results [
        {@input, :fixme}
      ]

      @part2_expected_results [
        {@input, :fixme}
      ]

      @tag :skip
      test "part1" do
        for {input, result} <- @part1_expected_results do
          assert part1(input) == result
        end
      end

      @tag :skip
      test "part2" do
        for {input, result} <- @part2_expected_results do
          assert part2(input) == result
        end
      end
    end
    """
  end

  def run([day]), do: prepare(day, DateTime.utc_now().year)
  def run([day, year]), do: prepare(day, year)
end
