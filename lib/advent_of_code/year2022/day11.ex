defmodule AdventOfCode.Year2022.Day11 do
  @moduledoc """
  --- Day 11: Monkey in the Middle ---
  https://adventofcode.com/2022/day/11
  """

  defp make_monkey(id) do
    %{
      # integer 0-n
      id: id,
      # integer items the monkey is holding
      items: [],
      # the function to determine the worry level during monkey inspection
      operation: nil,
      # the function that runs after the inspection, relief at first...
      post_operation: nil,
      # the function that determines which monkey to throw the item to, returns an integer
      # (a map now to track needed info as the lines are parsed)
      test: %{
        fun: nil,
        true_monkey: nil
      },
      # the number that the monkey divides by to test where to throw.
      # used to compute the lowest common multiple for modular math in part 2
      divisor: nil,
      # how many items the monkey has inspected
      inspections: 0
    }
  end

  # parse the input line by line.
  # keep a stack of monkeys and store the current line in the top one.
  defp parse_line(<<"Monkey ", n::8, _rest::binary>>, monkeys) do
    [make_monkey(String.to_integer(<<n>>)) | monkeys]
  end

  defp parse_line("  Starting items: " <> items, [monkey | monkeys]) do
    items = items |> String.split(", ") |> Enum.map(&String.to_integer/1)
    [%{monkey | items: items} | monkeys]
  end

  defp parse_line("  Operation: new = " <> operation, [monkey | monkeys]) do
    [arg1, op, arg2] = String.split(operation)

    op =
      case op do
        "*" -> &Kernel.*/2
        "+" -> &Kernel.+/2
      end

    op_fun = fn n ->
      args = [arg1, arg2] |> Enum.map(&if &1 == "old", do: n, else: String.to_integer(&1))
      apply(op, args)
    end

    [%{monkey | operation: op_fun} | monkeys]
  end

  defp parse_line("  Test: divisible by " <> n, [%{test: test} = monkey | monkeys]) do
    div_by = String.to_integer(n)
    [%{monkey | test: %{test | fun: &(rem(&1, div_by) == 0)}, divisor: div_by} | monkeys]
  end

  defp parse_line("    If true: throw to monkey " <> n, [%{test: test} = monkey | monkeys]) do
    [%{monkey | test: %{test | true_monkey: String.to_integer(n)}} | monkeys]
  end

  defp parse_line("    If false: throw to monkey " <> n, [%{test: test} = monkey | monkeys]) do
    test_fn = &if test.fun.(&1), do: test.true_monkey, else: String.to_integer(n)
    [%{monkey | test: test_fn} | monkeys]
  end

  defp parse_line(_, monkeys), do: monkeys

  defp monkey_initial_state(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce([], &parse_line/2)
    |> Enum.reverse()
  end

  defp start_monkey_agents!(monkeys) do
    monkeys
    |> Enum.map(fn %{id: id} = monkey ->
      {:ok, pid} = Agent.start_link(fn -> monkey end)
      {id, pid}
    end)
    |> Map.new()
  end

  defp stop_monkey_agents!(agents) do
    for {_, pid} <- agents, do: Agent.stop(pid)
  end

  defp simulate_n_rounds(agents, n),
    do: Stream.repeatedly(fn -> monkey_round(agents) end) |> Enum.take(n)

  defp monkey_round(agents) do
    agents
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.each(&monkey_turn(elem(&1, 1), agents))
  end

  defp monkey_turn(agent, agents), do: Agent.update(agent, &handle_items(&1, agents))

  # a monkey with no items is done with it's turn.
  defp handle_items(%{items: []} = monkey, _agents), do: monkey

  # inspect the top item, test it, and throw it to another monkey agent.
  defp handle_items(%{items: [item | items]} = monkey, agents) do
    %{operation: op, post_operation: post_op, test: test, inspections: n} = monkey
    item = op.(item) |> post_op.()
    recipient_id = test.(item)
    recipient_pid = Map.get(agents, recipient_id)
    Agent.cast(recipient_pid, &receive_item(&1, item))
    handle_items(%{monkey | items: items, inspections: n + 1}, agents)
  end

  # receive an item and enqueue it.
  defp receive_item(%{items: items} = monkey, item) do
    %{monkey | items: items ++ [item]}
  end

  # get the number of times this monkey agent has inspected an item.
  defp inspections(agent), do: Agent.get(agent, &Map.get(&1, :inspections))

  defp monkey_business(agents) do
    agents
    |> Enum.map(&inspections(elem(&1, 1)))
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def part1(input) do
    agents =
      input
      |> monkey_initial_state()
      |> Enum.map(fn monkey -> %{monkey | post_operation: &Integer.floor_div(&1, 3)} end)
      |> start_monkey_agents!()

    simulate_n_rounds(agents, 20)
    monkey_business = monkey_business(agents)
    stop_monkey_agents!(agents)
    monkey_business
  end

  def part2(input) do
    monkeys = monkey_initial_state(input)

    lcm =
      monkeys
      |> Enum.map(&Map.get(&1, :divisor))
      |> Enum.product()

    agents =
      monkeys
      |> Enum.map(fn monkey -> %{monkey | post_operation: &rem(&1, lcm)} end)
      |> start_monkey_agents!()

    simulate_n_rounds(agents, 10_000)
    monkey_business = monkey_business(agents)
    stop_monkey_agents!(agents)
    monkey_business
  end
end
