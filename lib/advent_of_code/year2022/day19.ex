defmodule AdventOfCode.Year2022.Day19 do
  @moduledoc """
  --- Day 19: Not Enough Minerals ---
  https://adventofcode.com/2022/day/19
  """

  defp blueprints(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce([], &add_blueprint/2)
    |> Enum.reverse()
  end

  defp add_blueprint(row, blueprints) do
    [blueprint_num | costs] =
      Regex.scan(~r/\d+/, row) |> List.flatten() |> Enum.map(&String.to_integer/1)

    [ore_ore, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian] = costs

    blueprint = %{
      number: blueprint_num,
      robots: %{
        ore: [ore: ore_ore],
        clay: [ore: clay_ore],
        obsidian: [ore: obsidian_ore, clay: obsidian_clay],
        geode: [ore: geode_ore, obsidian: geode_obsidian]
      },
      max_prices: %{
        ore: Enum.max([ore_ore, clay_ore, obsidian_ore, geode_ore]),
        clay: obsidian_clay,
        obsidian: geode_obsidian
      }
    }

    [blueprint | blueprints]
  end

  defp initial_robot_state, do: %{ore: 1, clay: 0, obsidian: 0}

  defp initial_material_state, do: %{ore: 0, clay: 0, obsidian: 0, geode: 0}

  # can we plan to build a robot?
  # we must have the robots that make the needed materials.
  defp has_prerequisite_robots?({_robot, price}, robots) do
    Enum.all?(price, fn {type, _} -> Map.get(robots, type) > 0 end)
  end

  # figure out what robots to build and how long until they can be built.
  # eg: {:ore, 2} means we will have enough material to build an ore robot in 2
  # turns.
  #
  # rules:
  # - we are not already making enough per minute to buy the most expensive robot
  #   that requires the material.
  # - we do not have enough material to build the most expensive robot every turn
  #   already.
  defp goal_robots(blueprint, minutes_remaining, robots, materials) do
    blueprint.robots
    |> Enum.filter(&has_prerequisite_robots?(&1, robots))
    |> Enum.filter(fn
      {:geode, _price} ->
        true

      {robot, _price} ->
        max_price = Map.get(blueprint.max_prices, robot, 0)
        num_robots = Map.get(robots, robot, 0)
        on_hand = Map.get(materials, robot)

        num_robots < max_price and
          num_robots * minutes_remaining + on_hand < minutes_remaining * max_price
    end)
    |> Enum.map(fn {robot, price} -> {robot, minutes_to_skip(price, robots, materials) + 1} end)
    |> Enum.reject(fn {_, skip} -> skip >= minutes_remaining end)
  end

  # how many minutes until we have enough materials to build the robot.
  defp minutes_to_skip(price, robots, materials) do
    price
    |> Enum.map(fn {type, cost} ->
      needed = cost - Map.get(materials, type)
      per_minute = Map.get(robots, type)

      if needed > 0, do: ceil(needed / per_minute), else: 0
    end)
    |> Enum.max()
  end

  # calculate the remaining materials after building a robot
  defp spend_materials(robot, blueprint, materials) do
    blueprint.robots
    |> Map.get(robot)
    |> Enum.reduce(materials, fn {material, cost}, materials ->
      Map.update!(materials, material, &(&1 - cost))
    end)
  end

  # when building a geode robot, add all the geodes it will produce in the time remaining.
  defp build(:geode, minutes_remaining, blueprint, robots, materials) do
    materials =
      spend_materials(:geode, blueprint, materials)
      |> Map.update!(:geode, &(&1 + minutes_remaining))

    {robots, materials}
  end

  # add one of the robots and spend the materials
  defp build(robot, _minutes_remaining, blueprint, robots, materials) do
    materials = spend_materials(robot, blueprint, materials)
    {Map.update!(robots, robot, &(&1 + 1)), materials}
  end

  defp collect_materials(robots, materials, minutes) do
    robots
    |> Enum.reduce(materials, fn {type, num_robots}, materials ->
      Map.update!(materials, type, fn on_hand -> on_hand + num_robots * minutes end)
    end)
  end

  defp max_geodes(blueprint, total_minutes, minute, robots, materials) do
    minutes_remaining = total_minutes - minute
    goal_robots = goal_robots(blueprint, minutes_remaining, robots, materials)
    current_geodes = Map.get(materials, :geode)

    cond do
      length(goal_robots) > 0 ->
        goal_robots
        |> Enum.map(fn {robot, skip} ->
          minute = minute + skip
          materials = collect_materials(robots, materials, skip)
          {robots, materials} = build(robot, total_minutes - minute, blueprint, robots, materials)
          max_geodes(blueprint, total_minutes, minute, robots, materials)
        end)
        |> Enum.max()

      true ->
        current_geodes
    end
  end

  # map the collection asynchronously.
  defp pmap(collection, fun, timeout \\ :infinity) do
    collection
    |> Enum.map(&Task.async(fn -> fun.(&1) end))
    |> Enum.map(&Task.await(&1, timeout))
  end

  def part1(input) do
    robots = initial_robot_state()
    materials = initial_material_state()

    input
    |> blueprints()
    |> pmap(&(&1.number * max_geodes(&1, 24, 0, robots, materials)))
    |> Enum.sum()
  end

  def part2(input) do
    robots = initial_robot_state()
    materials = initial_material_state()

    input
    |> blueprints()
    |> Enum.take(3)
    |> pmap(&max_geodes(&1, 32, 0, robots, materials))
    |> Enum.product()
  end
end
