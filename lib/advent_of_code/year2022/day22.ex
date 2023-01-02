defmodule AdventOfCode.Year2022.Day22 do
  @moduledoc """
  --- Day 22: Monkey Map ---
  https://adventofcode.com/2022/day/22
  """

  alias AdventOfCode.Grid
  alias AdventOfCode.Math

  defp parse_path(s, acc \\ [])

  defp parse_path("", acc), do: acc |> Enum.reverse()
  defp parse_path(<<"R", rest::binary>>, acc), do: parse_path(rest, [:right | acc])
  defp parse_path(<<"L", rest::binary>>, acc), do: parse_path(rest, [:left | acc])

  defp parse_path(s, acc) do
    {n, rest} = Integer.parse(s)
    parse_path(rest, [n | acc])
  end

  defp parse_input(input) do
    [grid_s, path_s] = input |> String.split("\n\n")
    {Grid.new(grid_s), parse_path(path_s |> String.trim())}
  end

  # start in the leftmost open cell of the top row of cells.
  defp initial_point(%Grid{} = g) do
    {_x, y} = g.upper_left

    Grid.row(g, y)
    |> Enum.find(fn {_point, val} -> val == "." end)
    |> elem(0)
  end

  @facing_scores [
    right: 0,
    down: 1,
    left: 2,
    up: 3
  ]

  defp facing_score(facing), do: Keyword.get(@facing_scores, facing)
  defp facing(score), do: Keyword.keys(@facing_scores) |> Enum.at(score)

  defp rotate(facing, direction, rotations \\ 1)

  defp rotate(facing, :right, rotations) do
    Math.mod(facing_score(facing) + rotations, 4)
    |> facing()
  end

  defp rotate(facing, :left, rotations) do
    Math.mod(facing_score(facing) - rotations, 4)
    |> facing()
  end

  # calculate the next point along the facing.
  # if leaving the map, use the portal function to figure out where to go.
  defp next_point(%Grid{} = g, point, facing, portal_fun) do
    next_point = Grid.move(point, facing)
    val = Grid.at(g, next_point)

    case val do
      :empty -> portal_fun.(point, facing, g)
      _ -> {next_point, facing}
    end
  end

  # wrap around to the other side and maintain facing.
  defp wrap_portal({x, _y}, direction, %Grid{} = g) when direction in [:up, :down] do
    col = g |> Grid.col(x)

    case direction do
      :up -> {col |> List.last() |> elem(0), :up}
      :down -> {col |> hd() |> elem(0), :down}
    end
  end

  defp wrap_portal({_x, y}, direction, %Grid{} = g) when direction in [:left, :right] do
    row = g |> Grid.row(y)

    case direction do
      :left -> {row |> List.last() |> elem(0), :left}
      :right -> {row |> hd() |> elem(0), :right}
    end
  end

  # calculate the size of each cube face.
  defp face_size(%Grid{} = g) do
    width = Grid.width(g)
    height = Grid.height(g)
    AdventOfCode.Math.gcd(width, height)
  end

  # find the corners to begin zipping the face edges.
  defp corner_points(%Grid{} = g) do
    g
    |> Grid.map(fn _g, {p, _val} -> {p, g |> Grid.neighbors(p, diagonals: true)} end)
    # a corner has neighbors on all sides but 1
    |> Enum.filter(fn {_p, neighbors} ->
      7 == neighbors |> Enum.filter(&(Grid.at(g, &1) != :empty)) |> length()
    end)
    |> Enum.map(fn {p, _} -> p end)
  end

  # the initial points and directions along the edges of the faces that will be zipped together.
  defp face_zippers(%Grid{} = g) do
    g
    |> corner_points()
    |> Enum.map(fn p ->
      neighbors = Grid.neighbors(g, p, diagonals: true)
      empty_neighbor = neighbors |> Enum.find(&(Grid.at(g, &1) == :empty))

      corner_directions(p, empty_neighbor)
      |> Enum.map(fn {d, _} = directions -> {Grid.move(p, d), directions} end)
    end)
  end

  # the directions along the face edge and pointing away from the edge for each kind of corner.
  defp corner_directions({x1, y1}, {x2, y2}) do
    cond do
      x2 > x1 and y2 < y1 -> [{:right, :up}, {:up, :right}]
      x2 > x1 and y2 > y1 -> [{:right, :down}, {:down, :right}]
      x2 < x1 and y2 > y1 -> [{:left, :down}, {:down, :left}]
      x2 < x1 and y2 < y1 -> [{:left, :up}, {:up, :left}]
    end
  end

  # the points along the face edge along with the direction to leave the face.
  # these are the keys in the portal map.
  defp face_edge_points(%Grid{} = g, {point, {edge_d, out_d}}) do
    Stream.iterate(point, fn p -> Grid.move(p, edge_d) end)
    |> Enum.take(face_size(g))
    |> Enum.map(&{&1, out_d})
  end

  # the point and directions for the next face corner from the current one.
  defp next_face_corner(%Grid{} = g, {point, {edge_d, out_d}}) do
    face_size = face_size(g)
    next_point = Grid.move_n(point, edge_d, face_size)

    cond do
      # continue with this facing.
      Grid.at(g, next_point) != :empty ->
        {next_point, {edge_d, out_d}}

      # turn right or left at the corner.
      true ->
        [
          {rotate(edge_d, :right), rotate(out_d, :right)},
          {rotate(edge_d, :left), rotate(out_d, :left)}
        ]
        |> Enum.map(&{Grid.move_n(point, edge_d, face_size - 1), &1})
        |> Enum.find(fn {p, {d, _}} -> Grid.at(g, Grid.move(p, d)) != :empty end)
    end
  end

  # all the face corners starting from a corner.
  # stop when reaching another corner or when both faces being zipped have changed directions.
  defp face_corners(%Grid{} = g, {point, {edge_d, out_d}}, corner_points) do
    Stream.iterate({point, {edge_d, out_d}}, &next_face_corner(g, &1))
    |> Enum.reduce_while([], fn {p, {edge_d, out_d}}, acc ->
      cond do
        p in corner_points -> {:halt, acc |> Enum.reverse()}
        true -> {:cont, [{p, {edge_d, out_d}} | acc]}
      end
    end)
  end

  # zip the faces together, creating a portal map.
  defp zip_faces([a, b], %Grid{} = g, corner_points, portal_map) do
    {_, {orig_d1, _}} = a
    {_, {orig_d2, _}} = b

    Enum.zip(face_corners(g, a, corner_points), face_corners(g, b, corner_points))
    |> Enum.reduce_while({{orig_d1, orig_d2}, portal_map}, fn {corner_a, corner_b}, acc ->
      {{last_d1, last_d2}, acc} = acc
      {_p1, {edge_d1, _out_d1}} = corner_a
      {_p2, {edge_d2, _out_d2}} = corner_b

      cond do
        edge_d1 != last_d1 and edge_d2 != last_d2 ->
          {:halt, acc}

        true ->
          portals =
            Enum.zip(face_edge_points(g, corner_a), face_edge_points(g, corner_b))
            |> Enum.flat_map(fn {{a_p, a_d}, {b_p, b_d}} ->
              [
                {{a_p, a_d}, {b_p, rotate(b_d, :right, 2)}},
                {{b_p, b_d}, {a_p, rotate(a_d, :right, 2)}}
              ]
            end)
            |> Map.new()

          {:cont, {{edge_d1, edge_d2}, Map.merge(acc, portals)}}
      end
    end)
  end

  # create the portal map for the cube.
  # %{{leaving_point, facing} => {destination_point, new_facing}}
  defp portal_map(%Grid{} = g) do
    corner_points = corner_points(g)

    g
    |> face_zippers()
    |> Enum.reduce(%{}, &zip_faces(&1, g, corner_points, &2))
  end

  # create a function that can use the portal map to calculate the next point to
  # move to when going over the edge of the cube.
  defp cube_portal_fun(%Grid{} = g) do
    portal_map = portal_map(g)
    fn point, direction, _g -> Map.get(portal_map, {point, direction}) end
  end

  # advance the state by either moving or rotating.
  defp advance_state([], %Grid{}, {x, y}, facing, _), do: {y + 1, x + 1, facing_score(facing)}

  defp advance_state([:right | path], %Grid{} = g, point, facing, portal_fun),
    do: advance_state(path, g, point, rotate(facing, :right), portal_fun)

  defp advance_state([:left | path], %Grid{} = g, point, facing, portal_fun),
    do: advance_state(path, g, point, rotate(facing, :left), portal_fun)

  defp advance_state([0 | path], %Grid{} = g, point, facing, portal_fun),
    do: advance_state(path, g, point, facing, portal_fun)

  defp advance_state([n | path], %Grid{} = g, point, facing, portal_fun) do
    {next_point, new_facing} = next_point(g, point, facing, portal_fun)
    val = Grid.at(g, next_point)

    case val do
      {:ok, "#"} ->
        # hit a wall
        advance_state(path, g, point, facing, portal_fun)

      {:ok, "."} ->
        # move to empty space
        advance_state([n - 1 | path], g, next_point, new_facing, portal_fun)
    end
  end

  def part1(input) do
    {g, path} = parse_input(input)
    {row, col, facing} = advance_state(path, g, initial_point(g), :right, &wrap_portal/3)

    row * 1000 + 4 * col + facing
  end

  def part2(input) do
    {g, path} = input |> parse_input()
    {row, col, facing} = advance_state(path, g, initial_point(g), :right, cube_portal_fun(g))
    row * 1000 + 4 * col + facing
  end
end
