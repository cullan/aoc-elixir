defmodule AdventOfCode.Year2015.Day07 do
  @moduledoc """
  --- Day 7: Some Assembly Required ---
  https://adventofcode.com/2015/day/7
  """

  @doc """
  Make a Map of wire ids to instructions.

  eg: "x LSHIFT 2 -> f" => %{f => {&Bitwise.bsl/2, :x, 2}}
  """
  def get_instructions(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, instruction, destination] = Regex.run(~r/(.*) -> ([a-z]+)/, line)
      {String.to_atom(destination), parse_instruction(instruction)}
    end)
    |> Map.new()
  end

  @doc """
  Parse a single instruction.

  examples:
  "123" => 123
  "a" => :a
  "NOT 1" => {&Bitwise.bnot/1, 1}
  "NOT a" => {&Bitwise.bnot/1, :a}
  "k AND m" => {&Bitwise.band/2, :k, :m}
  "k AND 1" => {&Bitwise.band/2, :k, 1}
  """
  def parse_instruction(s) do
    cond do
      # an integer signal is provided
      Regex.match?(~r/^\d+$/, s) ->
        String.to_integer(s)

      # the wire with this id is directly connected
      Regex.match?(~r/^[a-z]+$/, s) ->
        String.to_atom(s)

      # handle NOT being unary
      String.starts_with?(s, "NOT ") ->
        {gate_fn("NOT"), s |> String.slice(4..-1) |> int_or_atom()}

      # handle binary operations
      Regex.match?(~r/^\w+ [A-Z]+ \w+$/, s) ->
        [a, gate, b] = String.split(s)
        {gate_fn(gate), int_or_atom(a), int_or_atom(b)}

      true ->
        {:error, s}
    end
  end

  @doc """
  Get the function that will simulate the given gate.
  """
  def gate_fn(name) do
    case name do
      "NOT" -> &Bitwise.bnot/1
      "AND" -> &Bitwise.band/2
      "OR" -> &Bitwise.bor/2
      "LSHIFT" -> &Bitwise.bsl/2
      "RSHIFT" -> &Bitwise.bsr/2
      _ -> :error
    end
  end

  @doc """
  Try to convert the string to an integer. If it fails, make an atom instead.
  """
  def int_or_atom(s) do
    with {n, ""} <- Integer.parse(s) do
      n
    else
      :error -> String.to_atom(s)
    end
  end

  @doc """
  Get the current signal value of the wire.

  It could be an integer or the id of another wire. If the latter, look it up.
  If it isn't resolved yet, return the id, and we can try again later.
  """
  def get_signal(_, val) when is_integer(val), do: val

  def get_signal(signals, id) do
    val = Map.get(signals, id)

    cond do
      is_integer(val) -> val
      true -> id
    end
  end

  @doc """
  Simulate the logic gate.

  If the input values are not yet resolved, just return the instruction as is.
  """
  def simulate_gate(signals, gate, args) do
    args = Enum.map(args, &get_signal(signals, &1))

    if Enum.all?(args, &is_integer/1) do
      <<result::unsigned-16>> = <<apply(gate, args)::signed-16>>
      result
    else
      [gate, args] |> List.flatten() |> List.to_tuple()
    end
  end

  @doc """
  Calculate the signal from the instruction.

  Look up the signals of input wires. If all inputs are resolved, the current
  wire signal can now be calculated.
  """
  # the signal is already calculated, return it
  def calculate_instruction(_, {id, i}) when is_integer(i), do: {id, i}
  # the signal is defined by another wire_id, look it up, it might be resolved
  def calculate_instruction(signals, {id, a}) when is_atom(a), do: {id, get_signal(signals, a)}
  # calculate unary gate
  def calculate_instruction(signals, {id, {gate, a}}), do: {id, simulate_gate(signals, gate, [a])}
  # calculate binary gate
  def calculate_instruction(signals, {id, {gate, a, b}}),
    do: {id, simulate_gate(signals, gate, [a, b])}

  @doc """
  Find the signals that have been calculated.
  """
  def solved(signals),
    do: signals |> Map.to_list() |> Enum.filter(&is_integer(elem(&1, 1))) |> Map.new()

  @doc """
  Calculate the signals from the instructions.

  After each step, see if all the signals have been resolved. If not, try again.
  """
  def calculate_signals(signals) do
    signals = Map.new(signals, &calculate_instruction(signals, &1))

    if signals == solved(signals) do
      signals
    else
      calculate_signals(signals)
    end
  end

  def part1(input) do
    input
    |> get_instructions()
    |> calculate_signals()
    |> Map.get(:a)
  end

  def part2(input) do
    original_a_val = part1(input)

    input
    |> get_instructions()
    |> Map.put(:b, original_a_val)
    |> calculate_signals()
    |> Map.get(:a)
  end
end
