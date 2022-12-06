defmodule AdventOfCode.Year2022.Day05 do
  @moduledoc """
  --- Day 5: Supply Stacks ---
  https://adventofcode.com/2022/day/5
  """

  @doc """
  Make a list of the crate ids in the current layer.

  examples:
  "    [D]    " => [?\s ?D ?\s]
  "[N] [C]    " => [?N ?C ?\s]
  "[Z] [M] [P]" => [?Z ?M ?P]
  """
  def read_crates(s, crates \\ [])

  def read_crates(<<_::8, id::8, _::8*2, rest::binary>>, crates),
    do: read_crates(rest, [id | crates])

  def read_crates(<<_::8, id::8, rest::binary>>, crates), do: read_crates(rest, [id | crates])
  def read_crates(_, crates), do: Enum.reverse(crates)

  @doc """
  Push the crate id onto the correct stack.

  Skip if the crate id is not in [A-Z] (nothing was there).
  eg: {2, ?C}, %{"2" => [?M]} => %{"2" => [?C ?M]}
  """
  def push_crate({crate_id, stack_id}, stacks) when crate_id > 64 and crate_id < 91,
    do: Map.update(stacks, Integer.to_string(stack_id), [crate_id], &[crate_id | &1])

  def push_crate({_, _}, stacks), do: stacks

  @doc """
  Push all the crate ids in the current layer onto the correct stacks.
  """
  def push_crates(layer, stacks) do
    layer
    |> read_crates()
    |> Stream.with_index(1)
    |> Enum.reduce(stacks, &push_crate/2)
  end

  @doc """
  Build a map of stacks.
  "    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 " =>
  %{ "1" => [?N ?Z], "2" => [?D ?C ?M], "3" => [?P], ...etc }
  """
  def parse_stacks(stacks) do
    stacks
    |> String.split("\n")
    # ignore last line with stack numbers
    |> Enum.slice(0..-2)
    |> Enum.reduce(%{}, &push_crates/2)
    |> Map.new(fn {k, v} -> {k, Enum.reverse(v)} end)
  end

  def parse_instruction(instruction) do
    [_, count, source, destination] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, instruction)
    {String.to_integer(count), source, destination}
  end

  def parse_instructions(instructions),
    do: instructions |> String.trim() |> String.split("\n") |> Enum.map(&parse_instruction/1)

  def parse_input(input) do
    [stacks, instructions] = input |> String.split("\n\n")
    {parse_stacks(stacks), parse_instructions(instructions)}
  end

  @doc """
  Move the items from the source to the destination.
  """
  def move(mover, {count, source, destination}, stacks) do
    items =
      stacks
      |> Map.get(source)
      |> Enum.take(count)

    items = if mover == :CrateMover9000, do: Enum.reverse(items), else: items

    stacks
    |> Map.update!(destination, &Enum.concat(items, &1))
    |> Map.update!(source, &Enum.drop(&1, count))
  end

  @doc """
  Find the crate ids that are at the stop of each stack and make a string.
  """
  def top_crates(input, mover) do
    {stacks, instructions} = parse_input(input)

    instructions
    |> Enum.reduce(stacks, &move(mover, &1, &2))
    # Map.values/1 seemed to return the stacks sorted by id, but sort them just in case
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0), :asc)
    |> Enum.map(&hd(elem(&1, 1)))
    |> to_string()
  end

  def part1(input) do
    top_crates(input, :CrateMover9000)
  end

  def part2(input) do
    top_crates(input, :CrateMover9001)
  end
end
