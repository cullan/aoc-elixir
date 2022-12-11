defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  @doc """
  Get the location that inputs and last fetched time will be cached.
  """
  def cache_dir do
    [System.get_env("XDG_CACHE_HOME", "~/.cache"), "/advent_of_code"]
    |> Path.join()
    |> Path.expand()
  end

  @doc """
  Zero pad the integer day to be width 2.

  eg: 2 => 02, 11 => 11
  """
  def zero_pad(day), do: "#{day}" |> String.pad_leading(2, "0")

  defp config(), do: Application.get_all_env(:advent_of_code)

  defp headers,
    do: [
      {'cookie', String.to_charlist("session=" <> Keyword.get(config(), :session_key))},
      {'User-Agent', String.to_charlist(Keyword.get(config(), :user_agent))}
    ]

  defp base_url(day, year), do: 'https://adventofcode.com/#{year}/day/#{day}'

  def fetch!(:input, day, year) do
    {:ok, input} = fetch_url('#{base_url(day, year)}/input')
    input
  end

  def fetch!(:title, day, year) do
    {:ok, doc} = fetch_url('#{base_url(day, year)}')

    doc
    |> Floki.parse_document!()
    |> Floki.find("article h2")
    |> hd
    |> Floki.text()
  end

  defp last_fetched_time_file(), do: Path.join([cache_dir(), "last_fetched"])

  defp last_fetched_time!() do
    with {:ok, binary} <- last_fetched_time_file() |> File.read() do
      # an exception will be thrown if the file contains something that isn't a DateTime.
      {:ok, last_fetched, _} = DateTime.from_iso8601(binary)
      last_fetched
    else
      {:error, _} -> DateTime.from_unix!(1)
    end
  end

  defp update_last_fetched_time(),
    do: File.write(last_fetched_time_file(), DateTime.utc_now() |> to_string())

  defp check_cooldown() do
    cooldown = Keyword.get(config(), :api_cooldown_seconds)
    elapsed = DateTime.diff(DateTime.utc_now(), last_fetched_time!(), :second)
    if elapsed > cooldown, do: :ok, else: :too_soon
  end

  defp fetch_url(url) do
    with :ok <- check_cooldown(),
         {:ok, {{_, 200, 'OK'}, _, response}} <-
           :httpc.request(
             :get,
             {url, headers()},
             [ssl: [verify: :verify_none]],
             []
           ) do
      update_last_fetched_time()
      {:ok, to_string(response)}
    else
      :too_soon ->
        {:error, "it is too soon to call the API again."}

      {:error, error} ->
        update_last_fetched_time()
        {:error, error}
    end
  end

  def permutations([]), do: [[]]

  def permutations(lst) do
    for head <- lst, tail <- permutations(lst -- [head]), do: [head | tail]
  end
end
