defmodule AdventOfCode.Input do
  @moduledoc """
  Manage Advent of Code input cache.
  """

  @doc """
  Get the input for the specified day for the current year.

  If the input is already in the cache, it will come from there. Otherwise, it
  will be downloaded from the Advent of Code server.
  """
  def get!(day), do: get!(day, DateTime.utc_now().year)

  @doc """
  Get the input for the specified day and year.

  If the input is already in the cache, it will come from there. Otherwise, it
  will be downloaded from the Advent of Code server.
  """
  def get!(day, year) do
    cond do
      in_cache?(day, year) -> from_cache!(day, year)
      true -> download!(day, year)
    end
  end

  defp download!(day, year) do
    input = AdventOfCode.fetch!(:input, day, year)
    store_in_cache!(day, year, input)
    to_string(input)
  end

  defp input_cache_path(day, year),
    do: Path.join([AdventOfCode.cache_dir(), "input/#{year}/#{AdventOfCode.zero_pad(day)}"])

  defp in_cache?(day, year), do: input_cache_path(day, year) |> File.exists?()

  defp from_cache!(day, year), do: input_cache_path(day, year) |> File.read!()

  defp store_in_cache!(day, year, input) do
    path = input_cache_path(day, year)
    :ok = path |> Path.dirname() |> File.mkdir_p()
    :ok = File.write(path, input)
  end
end
