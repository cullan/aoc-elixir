defmodule AdventOfCode.Year2022.Day17 do
  @moduledoc """
  --- Day 17: Pyroclastic Flow ---
  https://adventofcode.com/2022/day/17
  """

  alias AdventOfCode.Grid

  # each point is specified by how far it is away from the upper left
  @shapes [
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}],
    [{2, 0}, {2, 1}, {0, 2}, {1, 2}, {2, 2}],
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
  ]

  # put a floor on the zeroth level
  defp make_initial_grid() do
    0..6
    |> Enum.reduce(Grid.new(), fn x, g -> Grid.put(g, {x, 0}, "-") end)
  end

  defp initial_state(input), do: {make_initial_grid(), jet_pattern_cycle(jet_pattern(input))}

  defp jet_pattern(input) do
    input
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(fn
      "<" -> :left
      ">" -> :right
    end)
  end

  defp jet_pattern_cycle(pattern), do: {Enum.with_index(pattern), []}

  # get the next item and the state of the cycle after removing it.
  # keep track of the original items and the remaining items after this one.
  defp next_item({items, [h | t]}), do: {h, {items, t}}
  # start over with the original pattern after the remaining items is empty.
  defp next_item({items = [h | t], []}), do: {h, {items, t}}

  # get the cycle after seeking ahead i items.
  defp seek(cycle, i) do
    {{_, j}, next_cycle} = next_item(cycle)

    if i == j do
      cycle
    else
      seek(next_cycle, i)
    end
  end

  defp height(shape), do: Enum.reduce(shape, 0, fn {_x, y}, acc -> max(acc, y + 1) end)

  # the points of the shape if the upper left is at the given point
  defp at_position(shape, {x, y}), do: for({dx, dy} <- shape, do: {x + dx, y + dy})

  # rocks start 2 from the wall and 3 above the highest rock or floor
  defp start_position(%Grid{upper_left: {_x, height}}, shape) do
    {2, height - height(shape) - 3}
  end

  defp push(position, %Grid{} = g, shape, direction) do
    can_push? =
      shape
      |> at_position(position)
      |> Enum.map(&Grid.move(&1, direction))
      # consider the grid with the rock included in order for bounds checking to work
      |> Enum.all?(fn {_x, y} = point ->
        Grid.in_bounds?(%Grid{g | upper_left: {0, y}}, point) and Grid.at(g, point) == :empty
      end)

    if can_push? do
      Grid.move(position, direction)
    else
      position
    end
  end

  defp fall(position, %Grid{} = g, shape) do
    can_fall? =
      shape
      |> at_position(position)
      |> Enum.map(&Grid.move(&1, :down))
      |> Enum.all?(fn point -> Grid.at(g, point) == :empty end)

    if can_fall? do
      Grid.move(position, :down)
    else
      position
    end
  end

  # calculate the position of the rock after pushing and falling.
  defp move(%Grid{} = g, shape, position, direction) do
    position
    |> push(g, shape, direction)
    |> fall(g, shape)
  end

  # calculate where the rock will end up.
  defp rock_landing_position(%Grid{} = g, shape, {_x, orig_y} = position, jet_pattern) do
    {{direction, _i}, jet_pattern} = next_item(jet_pattern)
    {_x, y} = next_position = move(g, shape, position, direction)

    # rock has fallen as far as it can go
    if orig_y == y do
      {next_position, jet_pattern}
    else
      rock_landing_position(g, shape, next_position, jet_pattern)
    end
  end

  # put the rock in the grid.
  defp place_rock(%Grid{} = g, shape, {x, y}) do
    for({dx, dy} <- shape, do: {x + dx, y + dy})
    |> Enum.reduce(g, fn p, g -> Grid.put(g, p, "#") end)
  end

  # calculate the jet cycle and grid after the rock is dropped.
  defp drop_rock(shape, {jets, %Grid{} = g}) do
    start_position = start_position(g, shape)
    {end_position, jets} = rock_landing_position(g, shape, start_position, jets)
    {jets, place_rock(g, shape, end_position)}
  end

  # drop n rocks and return the resulting grid.
  defp drop_rocks(%Grid{} = g, jets, n) do
    Stream.cycle(@shapes)
    |> Stream.take(n)
    |> Enum.reduce({jets, g}, &drop_rock/2)
    |> elem(1)
  end

  # make a key out of the state prior to dropping a rock.
  # we can check to see if we have seen this state before in order to skip ahead.
  defp key(shape, jets, %Grid{} = g) do
    {{_, i}, _} = next_item(jets)

    top_row =
      Grid.reduce(g, %{}, fn %Grid{upper_left: {_x, grid_top_y}}, {{x, y}, _val}, acc ->
        # check each point to see if it is the highest in its column.
        # if so, store how far away it is from the top.
        top_y = Map.get(acc, x, abs(grid_top_y))
        Map.put(acc, x, min(abs(grid_top_y - y), top_y))
      end)
      |> Enum.sort()
      |> Enum.map(&elem(&1, 1))

    {shape, i, top_row}
  end

  # keep track of the rock number and height for each key
  # when it has repeated, return the info needed to resume the simulation from a
  # multiple of the cycle size.
  defp find_cycle_step(shape, {seen, jets, %Grid{upper_left: {_x, ul_y}} = g, rock_number}) do
    {_shape, jet_index, top_layer} = key = key(shape, jets, g)

    if Map.has_key?(seen, key) do
      {:halt, {shape, jet_index, top_layer, Map.get(seen, key), {rock_number, abs(ul_y)}}}
    else
      {jets, g} = drop_rock(shape, {jets, g})
      {:cont, {Map.put(seen, key, {rock_number, abs(ul_y)}), jets, g, rock_number + 1}}
    end
  end

  defp find_cycle(%Grid{} = g, jets) do
    Stream.cycle(@shapes)
    |> Enum.reduce_while({%{}, jets, g, 0}, &find_cycle_step/2)
  end

  # make a grid that has a top layer with the given shape.
  defp grid_with_top_layer(top_layer) do
    max = top_layer |> Enum.max()

    top_layer
    |> Enum.with_index()
    |> Enum.reduce(make_initial_grid(), fn {distance_from_top, x}, g ->
      Grid.put(g, {x, -max + distance_from_top}, "#")
    end)
  end

  # skip ahead to the rock number with the nearest multiple of the cycle size without going over the goal.
  # start simulating up to the goal and add up the height.
  defp height_after_cycles(shape, jets, top_layer, {begin_n, begin_h}, {end_n, end_h}, goal_rock) do
    %Grid{upper_left: {_, initial_h}} = g = grid_with_top_layer(top_layer)
    cycle_size = end_n - begin_n
    cycles_to_skip = div(goal_rock - cycle_size, cycle_size)
    skip_to = begin_n + cycles_to_skip * cycle_size
    height_per_cycle = end_h - begin_h

    height =
      Stream.cycle(@shapes)
      |> Stream.drop_while(&(&1 != shape))
      |> Stream.take(goal_rock - skip_to)
      |> Enum.reduce({jets, g}, &drop_rock/2)
      |> elem(1)
      |> Map.get(:upper_left)
      |> elem(1)
      |> abs()

    # height up to where the cycle began, skipped height, height after resuming simulation.
    # subtract the height of the initial grid before resuming the simulation.
    begin_h + height_per_cycle * cycles_to_skip + height - abs(initial_h)
  end

  def part1(input) do
    {g, jets} = initial_state(input)

    g = drop_rocks(g, jets, 2022)
    {_, top_y} = g.upper_left
    abs(top_y)
  end

  def part2(input) do
    {g, jets} = initial_state(input)
    {shape, jet_index, top_layer, begin_rock, end_rock} = find_cycle(g, jets)
    jets = seek(jets, jet_index)
    height_after_cycles(shape, jets, top_layer, begin_rock, end_rock, 1_000_000_000_000)
  end
end
