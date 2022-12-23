defmodule AdventOfCode.Year2022.Day21 do
  @moduledoc """
  --- Day 21: Monkey Math ---
  https://adventofcode.com/2022/day/21
  """

  @operators %{
    "*" => &Kernel.*/2,
    "/" => &Kernel.div/2,
    "+" => &Kernel.+/2,
    "-" => &Kernel.-/2
  }

  def monkeys(input),
    do: input |> String.split("\n", trim: true) |> Enum.map(&monkey/1) |> Map.new()

  def monkey(s), do: monkey(s, nil)

  def monkey(<<id::binary-size(4), ": ", rest::binary>>, _),
    do: monkey(rest, String.to_atom(id))

  def monkey(<<c::8, _rest::binary>> = n, id) when c >= 48 and c <= 57,
    do: {id, %{number: String.to_integer(n)}}

  def monkey(<<id1::binary-size(4), " ", op::binary-size(1), " ", id2::binary-size(4)>>, id) do
    monkey = %{
      prerequisites: Enum.map([id1, id2], &String.to_atom/1),
      operator: op
    }

    {id, monkey}
  end

  # calculate the value for the monkey with given id.
  def calculate(%{} = monkeys, id) when is_atom(id) do
    monkey = Map.get(monkeys, id)

    case monkey do
      %{operator: op, prerequisites: [a, b]} ->
        op = Map.get(@operators, op)
        op.(calculate(monkeys, a), calculate(monkeys, b))

      %{number: num} ->
        num
    end
  end

  # calculate all the values, leaving the path from :root to :humn partially calculated.
  def calculate(%{} = monkeys) do
    path = path(monkeys)
    # compute leaf monkey values
    monkeys =
      Map.merge(
        monkeys,
        monkeys
        |> Enum.filter(fn {id, _} -> id not in path end)
        |> Enum.map(fn
          {id, %{number: _n} = m} -> {id, m}
          {id, _} -> {id, %{number: calculate(monkeys, id)}}
        end)
        |> Map.new()
      )

    # substitute values in the prereqs
    substituted =
      monkeys
      |> Enum.map(fn
        {id, %{number: _n} = m} ->
          {id, m}

        {id, m} ->
          {id, %{m | prerequisites: Enum.map(m.prerequisites, &substitute_value(monkeys, &1))}}
      end)
      |> Map.new()

    Map.merge(monkeys, substituted)
  end

  # find the path from :root to :humn.
  def path(monkeys, queue \\ [{:root, []}])

  def path(monkeys, [{monkey, path} | queue]) do
    if monkey == :humn do
      Enum.reverse([:humn | path])
    else
      prereqs =
        monkeys[monkey]
        |> Map.get(:prerequisites, [])
        |> Enum.map(&{&1, [monkey | path]})

      case prereqs do
        [] ->
          path(monkeys, queue)

        _ ->
          path(monkeys, queue ++ prereqs)
      end
    end
  end

  # get the value for the monkey, or its id if not calculated yet.
  def substitute_value(_, :humn), do: :humn

  def substitute_value(monkeys, id1) do
    case Map.get(monkeys, id1) do
      %{number: n} -> n
      _ -> id1
    end
  end

  # recursively solve for the variables on the path from :root to :humn.
  def solve({id, val}, monkeys) do
    %{operator: op, prerequisites: [a, b]} = Map.get(monkeys, id)
    {next_id, val} = solve(val, op, a, b)

    if next_id == :humn do
      val
    else
      solve({next_id, val}, monkeys)
    end
  end

  # determine the value of the variable.
  def solve(val, "*", n, x) when is_integer(n), do: {x, div(val, n)}
  def solve(val, "*", x, n) when is_integer(n), do: {x, div(val, n)}
  # luckily, this does not happen
  # def solve(val, "/", n, x) when is_integer(n), do: {x, div(n, val)}
  def solve(val, "/", x, n) when is_integer(n), do: {x, val * n}
  def solve(val, "+", n, x) when is_integer(n), do: {x, val - n}
  def solve(val, "+", x, n) when is_integer(n), do: {x, val - n}
  def solve(val, "-", n, x) when is_integer(n), do: {x, n - val}
  def solve(val, "-", x, n) when is_integer(n), do: {x, val + n}

  def part1(input) do
    input
    |> monkeys()
    |> calculate(:root)
  end

  def part2(input) do
    monkeys = input |> monkeys() |> calculate()

    {x, n} =
      case Map.get(monkeys, :root).prerequisites do
        [x, n] when is_integer(n) -> {x, n}
        [n, x] -> {x, n}
      end

    solve({x, n}, monkeys)
  end
end
