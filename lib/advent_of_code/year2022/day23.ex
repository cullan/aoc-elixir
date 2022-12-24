defmodule AdventOfCode.Year2022.Day23 do
  @moduledoc """
  --- Day 23: Unstable Diffusion ---
  https://adventofcode.com/2022/day/23
  """
  alias AdventOfCode.Grid

  defp grid(s), do: s |> Grid.new()

  # [{1, 1}, {1, 2}, ...]
  defp elf_positions(%Grid{} = g) do
    g
    |> Grid.filter(fn _g, {_, val} -> val == "#" end)
    |> Enum.map(&elem(&1, 0))
  end

  # calculate the points adjacent to the elf in the direction.
  defp adjacent_points({x, y}, direction),
    do: direction |> adjacent_offsets() |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)

  defp adjacent_offsets(:up), do: [{-1, -1}, {0, -1}, {1, -1}]
  defp adjacent_offsets(:down), do: [{-1, 1}, {0, 1}, {1, 1}]
  defp adjacent_offsets(:left), do: [{-1, -1}, {-1, 0}, {-1, 1}]
  defp adjacent_offsets(:right), do: [{1, -1}, {1, 0}, {1, 1}]

  # is the cell clear?
  defp clear?(%Grid{} = g, position) do
    case Grid.at(g, position) do
      {:ok, "#"} -> false
      _ -> true
    end
  end

  # are all the adjacent cells clear in the direction?
  defp clear?(%Grid{} = g, position, direction) do
    position
    |> adjacent_points(direction)
    |> Enum.all?(&clear?(g, &1))
  end

  # the elf at position will look around and pick a spot to move to.
  # if all clear or no direction is clear, don't move.
  # otherwise, pick the first clear direction.
  defp propose_move(%Grid{} = g, position, directions) do
    # [{:up, false}, {:down, true}, ...]
    clear_directions = directions |> Enum.map(&{&1, clear?(g, position, &1)})
    # [false, true, ...]
    clear_vals = clear_directions |> Enum.map(&elem(&1, 1))

    unless Enum.all?(clear_vals) or not Enum.any?(clear_vals) do
      clear_directions
      |> Enum.drop_while(fn {_direction, val} -> not val end)
      |> Enum.take(1)
      |> hd()
      |> elem(0)
    else
      nil
    end
  end

  # make a list of proposed moves for the elves and filter duplicates.
  # they are not allowed to move to the same position.
  defp moves(%Grid{} = g, directions) do
    propsed_moves =
      g
      |> elf_positions()
      |> Enum.flat_map(fn p ->
        case propose_move(g, p, directions) do
          nil -> []
          direction -> [{p, Grid.move(p, direction)}]
        end
      end)

    dups =
      propsed_moves
      |> Enum.frequencies_by(&elem(&1, 1))
      |> Enum.filter(fn {_p, count} -> count > 1 end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    propsed_moves
    |> Enum.filter(fn {_current, next} -> not MapSet.member?(dups, next) end)
  end

  defp move_elves(%Grid{} = g, moves) do
    moves
    |> Enum.reduce(g, fn {current, next}, g ->
      g
      |> Grid.put(current, ".")
      |> Grid.put(next, "#")
    end)
  end

  defp count_empty(%Grid{upper_left: {x1, y1}, lower_right: {x2, y2}} = g) do
    area = (x2 - x1 + 1) * (y2 - y1 + 1)
    num_elves = elf_positions(g) |> length()
    area - num_elves
  end

  defp direction_stream() do
    [:up, :down, :left, :right]
    |> Stream.cycle()
    |> Stream.chunk_every(4, 1)
  end

  defp rounds(%Grid{} = g, n) do
    direction_stream()
    |> Stream.take(n)
    |> Enum.reduce(g, &move_elves(&2, moves(&2, &1)))
  end

  defp final_round(%Grid{} = g) do
    direction_stream()
    |> Enum.reduce_while({1, g}, fn directions, {round, g} ->
      moves = moves(g, directions)

      case moves |> length() do
        0 -> {:halt, round}
        _ -> {:cont, {round + 1, move_elves(g, moves)}}
      end
    end)
  end

  def part1(input) do
    input
    |> grid()
    |> rounds(10)
    |> count_empty()
  end

  def part2(input) do
    input
    |> grid()
    |> final_round()
  end
end
