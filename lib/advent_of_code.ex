defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  def zero_pad(day), do: day |> String.pad_leading(2, "0")

  defp config(), do: Application.get_all_env(:advent_of_code)

  defp headers,
    do: [
      {'cookie', String.to_charlist("session=" <> Keyword.get(config(), :session_key))},
      {'User-Agent', String.to_charlist(Keyword.get(config(), :user_agent))}
    ]

  defp base_url(day, year), do: 'https://adventofcode.com/#{year}/day/#{day}'

  def fetch!(:input, day, year), do: fetch_url!('#{base_url(day, year)}/input')

  def fetch!(:description, day, year) do
    fetch_url!('#{base_url(day, year)}')
    |> Floki.parse_document!()
    |> Floki.find("article h2")
    |> hd
    |> Floki.text()
  end

  defp fetch_url!(url) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _, response}} =
      :httpc.request(
        :get,
        {url, headers()},
        [ssl: [verify: :verify_none]],
        []
      )

    to_string(response)
  end
end
