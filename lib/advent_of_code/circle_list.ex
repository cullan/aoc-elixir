defmodule AdventOfCode.CircleList do
  import Kernel, except: [length: 1]

  def new(), do: {[], []}
  def new(collection), do: {[], Enum.to_list(collection)}

  def reset({visited, items}), do: {[], visited |> Enum.reverse() |> Enum.concat(items)}

  def to_list(circle), do: circle |> reset() |> elem(1)

  def value({[], []}), do: nil
  def value({_, [item | _items]}), do: item
  def value({visited, []}), do: List.last(visited)

  def seek({[], []}, _), do: {[], []}
  def seek(lst, 0), do: lst

  def seek({_visited, []} = lst, n) when n > 0, do: seek(reset(lst), n)
  def seek({visited, [h | items]}, n) when n > 0, do: seek({[h | visited], items}, n - 1)

  def seek({[], items}, n) when n < 0, do: seek({Enum.reverse(items), []}, n)
  def seek({[h | visited], items}, n) when n < 0, do: seek({visited, [h | items]}, n + 1)

  def insert({visited, items}, item), do: {[item | visited], items}

  def pop({[], []}), do: {nil, {[], []}}
  def pop({visited, [h | items]}), do: {h, {visited, items}}
  def pop({_visited, []} = lst), do: pop(reset(lst))

  def remove(lst), do: pop(lst) |> elem(1)

  def length({visited, items}), do: Kernel.length(visited) + Kernel.length(items)

  def seek_while(lst, fun), do: seek_while(lst, fun, length(lst))
  def seek_while(_lst, _fun, 0), do: nil
  def seek_while({_visited, []} = lst, fun, n), do: seek_while(reset(lst), fun, n)

  def seek_while({visited, [h | items]} = lst, fun, n) do
    if fun.(h) do
      seek_while({[h | visited], items}, fun, n - 1)
    else
      lst
    end
  end

  def map({visited, items}, fun), do: {Enum.map(visited, fun), Enum.map(items, fun)}
end
