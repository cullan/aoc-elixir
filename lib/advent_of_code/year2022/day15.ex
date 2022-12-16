defmodule AdventOfCode.Year2022.Day15 do
  @moduledoc """
  --- Day 15: Beacon Exclusion Zone ---
  https://adventofcode.com/2022/day/15
  """

  defp sensor_log(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [sensor, beacon] = parse_line(row)
      {sensor, beacon, distance(sensor, beacon)}
    end)
  end

  defp parse_line(s) do
    ~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
    |> Regex.run(s)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp sensor_coverage_includes_row?({{_x, y}, _beacon, size}, row) do
    row >= y - size and row <= y + size
  end

  # min and max x values of sensor coverage over the given row
  defp horizontal_extent({{x, y} = _sensor, _, size}, row) do
    shift = size - abs(row - y)
    {x - shift, x + shift}
  end

  defp overlaps?({a_min, a_max}, {b_min, b_max}) do
    not Range.disjoint?(
      Range.new(a_min, a_max),
      Range.new(b_min, b_max)
    )
  end

  # combine overlapping ranges to make one larger range
  # eg: [{-2, 2}, {2, 3}, {4, 5}] => [{4, 5}, {-2, 3}] (no point in reversing for this)
  defp combine_ranges(ranges, acc \\ [])

  defp combine_ranges([{min, a_max} = a, {_, b_max} = b | rest], acc) do
    if overlaps?(a, b) do
      combine_ranges([{min, max(a_max, b_max)} | rest], acc)
    else
      combine_ranges([b | rest], [a | acc])
    end
  end

  defp combine_ranges(ranges, acc), do: ranges ++ acc

  # if any of the corners of the rectangle are outside the sensor range, the beacon could be in there
  defp not_fully_scanned_by_sensor?({x1, y1}, {x2, y2}, {sensor, _beacon, size}) do
    [{x1, y1}, {x2, y1}, {x1, y2}, {x2, y2}]
    |> Enum.any?(&(distance(&1, sensor) > size))
  end

  # none of the sensors can rule out this rectangle
  defp not_fully_scanned_by_sensors?(corner1, corner2, sensor_log) do
    Enum.all?(sensor_log, &not_fully_scanned_by_sensor?(corner1, corner2, &1))
  end

  # split the rectangle into four smaller rectangles that don't overlap.
  defp split_rectangle({x1, y1}, {x2, y2}) do
    mid_x = Integer.floor_div(x1 + x2, 2)
    mid_y = Integer.floor_div(y1 + y2, 2)

    [
      {{x1, y1}, {mid_x, mid_y}},
      {{mid_x + 1, y1}, {x2, mid_y}},
      {{x1, mid_y + 1}, {mid_x, y2}},
      {{mid_x + 1, mid_y + 1}, {x2, y2}}
    ]
    |> Enum.reject(fn {{x1, y1}, {x2, y2}} -> x1 > x2 or y1 > y2 end)
  end

  # the point must be outside the sensor range of all sensors
  defp verify_point(point, sensor_log) do
    Enum.all?(sensor_log, fn {sensor, _, size} -> distance(point, sensor) > size end)
  end

  # if the rectangle is not fully scanned, break it into smaller rectangles, and check those.
  # areas will be eliminated by sensor coverage or checking single points.
  # one point should not have been scanned and it will eventually be found.
  defp find_unscanned_point([{corner1, corner2} | stack], sensor_log) when corner1 == corner2 do
    if verify_point(corner1, sensor_log) do
      corner1
    else
      find_unscanned_point(stack, sensor_log)
    end
  end

  defp find_unscanned_point([{corner1, corner2} | stack], sensor_log) do
    if not_fully_scanned_by_sensors?(corner1, corner2, sensor_log) do
      find_unscanned_point(split_rectangle(corner1, corner2) ++ stack, sensor_log)
    else
      find_unscanned_point(stack, sensor_log)
    end
  end

  defp tuning_frequency({x, y}), do: x * 4_000_000 + y

  def part1(input, row \\ 2_000_000) do
    sensor_log =
      input
      |> sensor_log()
      |> Enum.filter(&sensor_coverage_includes_row?(&1, row))

    num_beacons =
      sensor_log
      |> Enum.map(&elem(&1, 1))
      |> Enum.filter(fn {_x, y} -> y == row end)
      |> MapSet.new()
      |> MapSet.size()

    num_scanned =
      sensor_log
      |> Enum.map(&horizontal_extent(&1, row))
      |> Enum.sort()
      |> combine_ranges()
      |> Enum.map(fn {min, max} -> 1 + max - min end)
      |> Enum.sum()

    num_scanned - num_beacons
  end

  def part2(input, max \\ 4_000_000) do
    sensor_log = sensor_log(input)

    beacon = find_unscanned_point([{{0, 0}, {max, max}}], sensor_log)
    tuning_frequency(beacon)
  end
end
