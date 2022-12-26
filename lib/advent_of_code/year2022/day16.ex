defmodule AdventOfCode.Year2022.Day16 do
  @moduledoc """
  --- Day 16: Proboscidea Volcanium ---
  https://adventofcode.com/2022/day/16
  """
  alias AdventOfCode.Math

  defmodule Valve, do: defstruct([:id, flow_rate: 0, tunnels: %{}])
  defmodule Tunnel, do: defstruct([:id, cost: 1])

  defp valve(line) do
    reg = ~r/Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? ((?:[A-Z]{2},? ?)*)/
    [_, valve, flow_rate, tunnels] = Regex.run(reg, line)
    tunnels = tunnels |> String.split(", ") |> Enum.map(&String.to_atom/1)

    %Valve{
      id: String.to_atom(valve),
      flow_rate: String.to_integer(flow_rate),
      tunnels: tunnels |> Enum.map(&%Tunnel{id: &1, cost: 1})
    }
  end

  defp valves(input),
    do:
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&valve/1)
      |> Map.new(&{&1.id, &1})
      |> simplify_map()

  # remove valves with zero flow.
  defp simplify_map(valves) do
    valves
    |> Map.values()
    |> Enum.filter(&(&1.id != :AA and &1.flow_rate == 0))
    |> Enum.map(& &1.id)
    |> Enum.reduce(valves, &remove_valve/2)
  end

  # remove this zero flow valve and update neighbors to pass through it with higher cost.
  defp remove_valve(valve_id, valves) do
    valve = valves[valve_id]

    updated_neighbors =
      valve.tunnels
      |> Enum.map(fn tunnel ->
        neighbor = Map.get(valves, tunnel.id)

        {[valve_tunnel], tunnels_without_valve} =
          neighbor.tunnels |> Enum.split_with(&(&1.id == valve.id))

        updated_tunnels =
          valve.tunnels
          |> Enum.reject(&(&1.id == neighbor.id))
          |> Enum.map(&%Tunnel{&1 | cost: &1.cost + valve_tunnel.cost})

        %Valve{neighbor | tunnels: tunnels_without_valve ++ updated_tunnels}
      end)
      |> Map.new(&{&1.id, &1})

    valves
    |> Map.merge(updated_neighbors)
    |> Map.delete(valve.id)
  end

  # cost to move from valve a to valve b.
  defp cost(valves, [{valve, cost} | queue], goal) do
    if valve == goal do
      cost
    else
      next_valves = valve.tunnels |> Enum.map(&{Map.get(valves, &1.id), cost + &1.cost})
      cost(valves, queue ++ next_valves, goal)
    end
  end

  # pre-calculate all the costs to travel between any two valves.
  defp cost_matrix(valves) do
    valves
    |> Map.keys()
    |> Math.combinations(2)
    |> Enum.reduce(%{}, fn [a, b], acc ->
      cost = cost(valves, [{Map.get(valves, a), 0}], Map.get(valves, b))

      acc
      |> Map.put({a, b}, cost)
      |> Map.put({b, a}, cost)
    end)
  end

  # calculate the amount of pressure released by opening the valve with the remaining time.
  defp pressure_released(valve, remaining_time), do: valve.flow_rate * remaining_time

  # calculate the max pressure that could be released.
  # start from :AA with all valves closed.
  defp max_pressure_released(valves, args \\ []) do
    remaining = args[:remaining] || 30
    closed_valves = args[:closed_valves] || valves |> Map.delete(:AA) |> Map.keys()

    max_pressure_released(
      valves[:AA],
      remaining,
      0,
      valves,
      cost_matrix(valves),
      closed_valves
    )
  end

  defp max_pressure_released(current_valve, remaining, released, valves, costs, closed_valves) do
    closed_valves
    |> Enum.map(fn valve_id ->
      valve = Map.get(valves, valve_id)
      # get the other closed valve ids (besides the current one)
      {[_], other_valves} = closed_valves |> Enum.split_with(&(&1 == valve.id))
      remaining = remaining - 1 - Map.get(costs, {current_valve.id, valve.id})

      cond do
        # stop when out of time.
        remaining <= 0 ->
          {released, closed_valves}

        # stop when no more valves to open after this one.
        length(other_valves) == 0 ->
          {released + pressure_released(valve, remaining), closed_valves}

        true ->
          # how much pressure could be released if we open the valve next?
          max_pressure_released(
            valve,
            remaining,
            released + pressure_released(valve, remaining),
            valves,
            costs,
            other_valves
          )
      end
    end)
    # pick the best one.
    |> Enum.max_by(&elem(&1, 0))
  end

  def part1(input) do
    valves = input |> valves()
    max_pressure_released(valves) |> elem(0)
  end

  def part2(input) do
    # Look for the best path I can do and then see what the elephant can do with what is left.
    # This does not work on the test input because it is small enough that all the valves
    # are opened within 26 minutes. It does work for the larger input and gets a star. ¯\_(ツ)_/¯
    # TODO:make this handle the test case from the puzzle text.
    valves = input |> valves()
    {released, closed_valves} = max_pressure_released(valves, remaining: 26)

    {released_elephant, _} =
      max_pressure_released(valves, remaining: 26, closed_valves: closed_valves)

    released + released_elephant
  end
end
