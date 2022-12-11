defmodule AdventOfCode.Math do
  @doc """
  Calculate the permutations of the list.
  """
  def permutations([]), do: [[]]

  def permutations(lst) do
    for head <- lst, tail <- permutations(lst -- [head]), do: [head | tail]
  end

  @doc """
  Calculate the greatest common denominator of the two numbers.
  """
  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  @doc """
  Calculate the least common multiple of the two numbers.
  """
  def lcm(a, b), do: div(abs(a * b), gcd(a, b))

  @doc """
  Calculate the least common multiple of the list of numbers.
  """
  def lcm([a]), do: a
  def lcm([a, b | rest]), do: lcm([lcm(a, b) | rest])
end
