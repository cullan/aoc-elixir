defmodule AdventOfCode.Year2022.Day07 do
  @moduledoc """
  --- Day 7: No Space Left On Device ---
  https://adventofcode.com/2022/day/7
  """

  def directory_tree(output_log, path \\ [], tree \\ %{})
  def directory_tree([], _path, tree), do: Map.get(tree, "/")

  def directory_tree([current | output_log], path, tree) do
    case String.split(current) do
      ["$", "cd", ".."] ->
        directory_tree(output_log, tl(path), tree)

      ["$", "cd", dir] ->
        directory_tree(output_log, [dir | path], add_dir(tree, [dir | path]))

      ["$", _] ->
        directory_tree(output_log, path, tree)

      ["dir", _] ->
        directory_tree(output_log, path, tree)

      [size, file_name] ->
        directory_tree(output_log, path, add_file(tree, path, {size, file_name}))
    end
  end

  def calc_path(path), do: Enum.intersperse(path, :children)

  def add_dir(tree, path) do
    name = hd(path)
    path = path |> Enum.reverse() |> calc_path()
    put_in(tree, path, get_in(tree, path) || %{name: name, files: [], children: %{}})
  end

  def add_file(tree, path, {size, file_name}) do
    path = path |> Enum.reverse() |> calc_path()

    update_in(tree, path, fn dir ->
      Map.update!(dir, :files, &[{file_name, String.to_integer(size)} | &1])
    end)
  end

  def walk(stack, function, acc \\ [])
  def walk(%{} = tree, f, acc), do: walk([tree], f, acc)
  def walk([], _, acc), do: acc

  def walk([%{children: children} = dir | stack], f, acc) do
    # push the children on the stack
    stack = children |> Map.values() |> Enum.reduce(stack, &[&1 | &2])
    # store the result of calling the function in the accumulator
    walk(stack, f, [f.(dir) | acc])
  end

  def sum_file_sizes(files), do: files |> Enum.map(&elem(&1, 1)) |> Enum.sum()

  def directory_size(directory) do
    sum_file_sizes(directory.files) +
      (directory.children |> Map.values() |> Enum.map(&directory_size/1) |> Enum.sum())
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> directory_tree()
    |> walk(&directory_size/1)
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  def part2(input) do
    tree =
      input
      |> String.split("\n", trim: true)
      |> directory_tree()

    unused_space = 70_000_000 - directory_size(tree)
    required_space = 30_000_000 - unused_space

    tree
    |> walk(&directory_size/1)
    |> Enum.filter(&(&1 >= required_space))
    |> Enum.min()
  end
end
