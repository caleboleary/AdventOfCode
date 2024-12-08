defmodule AdventOfCode.Day08 do
  @moduledoc """
  This was pretty fun and took some trial and error to find the math to get the antinodes.
  I basically just looked at the points in examples and figured out the math, which was actually
  only right for cases where the top point was to the left of the bottom point.

  So had to cirlce back and debug to figure out the right math for all point cases

  p2 was a little difficult to understand and I was plaugued with some silly bugs on my part
  as I went. I pretty immediately had the idea for stepping in each dir until oob.
  I think that was probably the AoC intent - to show you how to take 1 step with p1.
  """

  alias Helpers.CalbeGrid

  defp get_antinode_points({{p1x, p1y}, _}, {{p2x, p2y}, _}) do
    x_diff = p1x - p2x
    y_diff = p1y - p2y

    [
      {p1x + x_diff, p1y + y_diff},
      {p2x - x_diff, p2y - y_diff},
    ]
  end

  defp get_antinodes_for_freq(grid, frequency) do
    points_of_freq = CalbeGrid.filter_points(grid, fn cell -> cell == frequency end)

    grid_len = CalbeGrid.get_grid_len(grid)
    grid_width = CalbeGrid.get_grid_width(grid)

    # https://elixirforum.com/t/generate-all-combinations-having-a-fixed-array-size/26196
    combinations = for x <- points_of_freq, y <- points_of_freq, x != y && elem(x, 0) < elem(y, 0), do: [x, y]

    Enum.map(combinations, fn [point1, point2] ->
      get_antinode_points(point1, point2)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn {x, y} -> x >= 0 and x < grid_len and y >= 0 and y < grid_width end)
  end

  def part1(input) do

    grid = CalbeGrid.parse(input, "\n", "")

    unique_frequencies = String.replace(input, "\n", "")
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != "." end)

    Enum.flat_map(unique_frequencies, fn frequency ->
      get_antinodes_for_freq(grid, frequency)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp get_antinode_points_p2(grid, {{p1x, p1y}, _}, {{p2x, p2y}, _}) do
    x_diff = p1x - p2x
    y_diff = p1y - p2y

    limit = 1000

    subtract = Enum.reduce_while(1..limit, [], fn i, acc ->
      new_x = p2x - (x_diff * i)
      new_y = p2y - (y_diff * i)

      if CalbeGrid.get_is_point_in_bounds(grid, {new_x, new_y}) do
        {:cont, [{new_x, new_y} | acc]}
      else
        {:halt, acc}
      end
    end)

    add = Enum.reduce_while(1..limit, [], fn i, acc ->
      new_x = p1x + (x_diff * i)
      new_y = p1y + (y_diff * i)

      if CalbeGrid.get_is_point_in_bounds(grid, {new_x, new_y}) do
        {:cont, [{new_x, new_y} | acc]}
      else
        {:halt, acc}
      end
    end)

    subtract ++ add
  end

  defp get_antinodes_for_freq_p2(grid, frequency) do
    points_of_freq = CalbeGrid.filter_points(grid, fn cell -> cell == frequency end)

    if Enum.count(points_of_freq) >= 2 do

      grid_len = CalbeGrid.get_grid_len(grid)
      grid_width = CalbeGrid.get_grid_width(grid)

      # https://elixirforum.com/t/generate-all-combinations-having-a-fixed-array-size/26196
      combinations = for x <- points_of_freq, y <- points_of_freq, x != y && elem(x, 0) < elem(y, 0), do: [x, y]

      non_point_antinodes = Enum.map(combinations, fn [point1, point2] ->
        get_antinode_points_p2(grid, point1, point2)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(fn {x, y} -> x >= 0 and x < grid_len and y >= 0 and y < grid_width end)

      non_point_antinodes ++ Enum.map(points_of_freq, fn {pt, _} ->
       pt
      end)
    else
      []
    end
  end

  def part2(input) do
    grid = CalbeGrid.parse(input, "\n", "")

    unique_frequencies = String.replace(input, "\n", "")
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != "." end)

    Enum.flat_map(unique_frequencies, fn frequency ->
      get_antinodes_for_freq_p2(grid, frequency)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end
end
