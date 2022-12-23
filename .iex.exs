defmodule IExHelpers do
  defmacro workon(day, year \\ DateTime.utc_now().year) do
    quote do
      alias unquote(:"Elixir.AdventOfCode.Year#{year}.Day#{AdventOfCode.zero_pad(day)}")
      import unquote(:"Elixir.AdventOfCode.Year#{year}.Day#{AdventOfCode.zero_pad(day)}")
    end
  end
end

import IExHelpers

alias AdventOfCode.Grid
alias AdventOfCode.Math
alias AdventOfCode.CircleList

# default to displaying charlists as lists
# IO.inspect(item, charlists: :infer) can be used to manually view charlists
IEx.configure(inspect: [charlists: :as_lists])
