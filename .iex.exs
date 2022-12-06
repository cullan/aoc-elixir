defmodule IExHelpers do
  defmacro workon(day, year \\ DateTime.utc_now().year) do
    quote do
      alias unquote(:"Elixir.AdventOfCode.Year#{year}.Day#{AdventOfCode.zero_pad(day)}")
    end
  end
end

import IExHelpers
