defmodule AdventOfCode.Year2022.Day08 do
  @moduledoc """
  --- Day 8: Treetop Tree House ---
  https://adventofcode.com/2022/day/8
  """

  alias AdventOfCode.Grid

  @doc """
  Make a Grid of integers from the input string.
  """
  def make_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Grid.new()
  end

  # trees on the edge are visible
  def visible?(%Grid{}, {{0, _}, _}), do: true
  def visible?(%Grid{}, {{_, 0}, _}), do: true
  def visible?(%Grid{lower_right: {x1, _y}}, {{x, _}, _}) when x == x1, do: true
  def visible?(%Grid{lower_right: {_x, y1}}, {{_, y}, _}) when y == y1, do: true
  # look in each direction until finding a larger tree or the edge
  def visible?(%Grid{} = g, {point, val}) do
    [:up, :down, :left, :right]
    |> Enum.any?(&can_see_to_end?(g, val, Grid.line_segment_to_edge(g, point, &1)))
  end

  @doc """
  Determine if the tree height is greater than or equal to all others along the line segment.
  """
  def can_see_to_end?(%Grid{}, _, []), do: true

  def can_see_to_end?(%Grid{} = g, val, [point | ray]) do
    neighbor_val = Grid.at!(g, point)

    if neighbor_val < val do
      can_see_to_end?(g, val, ray)
    else
      false
    end
  end

  def count_visible_from_outside(%Grid{} = grid) do
    grid
    |> Grid.filter(&visible?/2)
    |> Enum.count()
  end

  def scenic_score(%Grid{} = g, {point, val}) do
    [:up, :down, :left, :right]
    |> Enum.map(&count_visible_trees(g, val, Grid.line_segment_to_edge(g, point, &1)))
    |> Enum.reduce(1, &*/2)
  end

  @doc """
  Count the visible trees along the line segment.
  """
  def count_visible_trees(%Grid{}, _, []), do: 0

  def count_visible_trees(%Grid{} = g, val, [point | ray]) do
    neighbor_val = Grid.at!(g, point)

    if val > neighbor_val do
      1 + count_visible_trees(g, val, ray)
    else
      1
    end
  end

  def part1(input) do
    input
    |> make_grid()
    |> count_visible_from_outside()
  end

  def part2(input) do
    input
    |> make_grid()
    |> Grid.map(&scenic_score/2)
    |> Enum.max()
  end
end
