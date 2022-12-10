defmodule AdventOfCode.Year2022.Day09 do
  @moduledoc """
  --- Day 9: Rope Bridge ---
  https://adventofcode.com/2022/day/9
  """

  @directions %{
    "U" => :up,
    "D" => :down,
    "R" => :right,
    "L" => :left
  }

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [direction, count] = String.split(row)
      {Map.get(@directions, direction), String.to_integer(count)}
    end)
  end

  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}
  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :up_right), do: {x + 1, y - 1}
  defp move({x, y}, :up_left), do: {x - 1, y - 1}
  defp move({x, y}, :down_right), do: {x + 1, y + 1}
  defp move({x, y}, :down_left), do: {x - 1, y + 1}

  defp move_toward({x1, y1} = p, {x2, y2}) do
    cond do
      x2 > x1 and y2 == y1 -> move(p, :right)
      x2 < x1 and y2 == y1 -> move(p, :left)
      x2 == x1 and y2 < y1 -> move(p, :up)
      x2 == x1 and y2 > y1 -> move(p, :down)
      x2 > x1 and y2 < y1 -> move(p, :up_right)
      x2 < x1 and y2 < y1 -> move(p, :up_left)
      x2 > x1 and y2 > y1 -> move(p, :down_right)
      x2 < x1 and y2 > y1 -> move(p, :down_left)
    end
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    |> :math.floor()
    |> trunc()
  end

  defp make_knots(n), do: Stream.duplicate({0, 0}, n) |> Enum.to_list()

  defp move_knot_pair(knot1, knot2, direction) do
    new_knot1 = move(knot1, direction)
    {new_knot1, move_linked_knot(new_knot1, knot2)}
  end

  defp move_linked_knot(knot1, knot2) do
    if distance(knot1, knot2) > 1, do: move_toward(knot2, knot1), else: knot2
  end

  defp move_knots(direction, knots, acc \\ [])

  defp move_knots(_direction, [], acc), do: {hd(acc), acc |> Enum.reverse()}

  defp move_knots(direction, [knot1, knot2 | knots], []) do
    {knot1, knot2} = move_knot_pair(knot1, knot2, direction)
    move_knots(direction, knots, [knot2, knot1])
  end

  defp move_knots(direction, [knot | knots], acc) do
    knot = move_linked_knot(hd(acc), knot)
    move_knots(direction, knots, [knot | acc])
  end

  defp step({_direction, 0}, acc), do: acc

  defp step({direction, count}, {knots, visited}) do
    {tail, knots} = move_knots(direction, knots)
    step({direction, count - 1}, {knots, MapSet.put(visited, tail)})
  end

  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce({make_knots(2), MapSet.new()}, &step/2)
    |> elem(1)
    |> MapSet.size()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.reduce({make_knots(10), MapSet.new()}, &step/2)
    |> elem(1)
    |> MapSet.size()
  end
end
