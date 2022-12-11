defmodule AdventOfCode.Math do
  @doc """
  Calculate the permutations of the list.
  """
  def permutations([]), do: [[]]

  def permutations(lst) do
    for head <- lst, tail <- permutations(lst -- [head]), do: [head | tail]
  end
end
