defmodule AdventOfCode.Year2015.Day09 do
  @moduledoc """
  --- Day 9: All in a Single Night ---
  https://adventofcode.com/2015/day/9
  """

  import AdventOfCode, only: [permutations: 1]

  def parse_line(s) do
    [_, a, b, distance] = Regex.run(~r/([A-Za-z]+) to ([A-Za-z]+) = (\d+)/, s)
    {a, b, String.to_integer(distance)}
  end

  def edges(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def nodes(edges) do
    edges
    |> Enum.reduce(MapSet.new(), fn {node1, node2, _}, acc ->
      acc
      |> MapSet.put(node1)
      |> MapSet.put(node2)
    end)
    |> MapSet.to_list()
  end

  def edge_map(edges) do
    edges
    |> Map.new(fn {a, b, distance} -> {"#{a}->#{b}", distance} end)
  end

  def nodes_and_edges(input) do
    edges = edges(input)
    nodes = nodes(edges)
    edges = edge_map(edges)
    {nodes, edges}
  end

  def distance(edges, [a, b]) do
    Map.get(edges, "#{a}->#{b}", Map.get(edges, "#{b}->#{a}"))
  end

  def total_path_distance(edges, path) do
    path
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&distance(edges, &1))
    |> Enum.sum()
  end

  def part1(input) do
    {nodes, edges} = nodes_and_edges(input)

    nodes
    |> permutations()
    |> Enum.map(&total_path_distance(edges, &1))
    |> Enum.min()
  end

  def part2(input) do
    {nodes, edges} = nodes_and_edges(input)

    nodes
    |> permutations()
    |> Enum.map(&total_path_distance(edges, &1))
    |> Enum.max()
  end
end
