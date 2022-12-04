defmodule AdventOfCode.Year2015.Day02 do
  @moduledoc """
  --- Day 2: I Was Told There Would Be No Math ---
  https://adventofcode.com/2015/day/2
  """

  # "2x3x4" => {2, 3, 4}
  def parse_dimensions(s),
    do: s |> String.split("x") |> Enum.map(&String.to_integer/1) |> List.to_tuple()

  def rectangle_area({length, width}), do: length * width

  def rectangular_prism_volume({length, width, height}), do: length * width * height

  @doc """
  Get the dimensions of each unique rectangular side of the prism.
  """
  def sides({l, w, h}), do: [{l, w}, {w, h}, {h, l}]

  @doc """
  Calculate the area of each side.
  """
  def side_areas(dimensions), do: dimensions |> sides() |> Enum.map(&rectangle_area/1)

  @doc """
  Calculate the total surface area from the areas of the sides.
  Each side has a corresponding opposite side that has the same area.
  """
  def surface_area(side_areas), do: (side_areas |> Enum.sum()) * 2

  @doc """
  Calculate the extra wrapping paper needed.
  It should cover the smallest side.
  """
  def slack(side_areas), do: Enum.min(side_areas)

  def wrapping_paper_required(dimensions) do
    dimensions
    |> side_areas()
    |> (&(surface_area(&1) + slack(&1))).()
  end

  def shortest_sides(dimensions), do: dimensions |> Tuple.to_list() |> Enum.sort() |> Enum.take(2)

  def ribbon_required(dimensions) do
    ribbon = (dimensions |> shortest_sides() |> Enum.sum()) * 2
    bow = rectangular_prism_volume(dimensions)
    ribbon + bow
  end

  def part1(input) do
    input
    |> String.split()
    |> Enum.map(fn present ->
      present
      |> parse_dimensions()
      |> wrapping_paper_required()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split()
    |> Enum.map(fn present ->
      present
      |> parse_dimensions()
      |> ribbon_required()
    end)
    |> Enum.sum()
  end
end
