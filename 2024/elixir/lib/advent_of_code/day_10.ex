defmodule AdventOfCode.Day10 do
  @moduledoc """
  haha, I was kind of dumb, I spent so long on p1 fixing up my half dead dijkstra impl from prev year
  and it did finally work if slowly to get p1 answer, but then didn't really fit at all with p2
  so I just did a quick bfs for p2 and it worked fine with less code and less headache.

  I could super easly sub in the bfs for p1 as well, but I'm going to share my idiocy instead

  and hey if dijkstra is helpful for some other problem later, it works now!
  """

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    input
    |> CalbeGrid.parse("\n", "")
    |> CalbeGrid.visualize_grid()
  end

  defp get_possible_moves(grid, {curr_x, curr_y}, _) do

    curr_value = CalbeGrid.get_by_x_y(grid, curr_x, curr_y)

    potential_coords = [
      {curr_x + 1, curr_y},
      {curr_x - 1, curr_y},
      {curr_x, curr_y + 1},
      {curr_x, curr_y - 1}
    ]

    Enum.filter(potential_coords, fn {x, y} ->
      value = CalbeGrid.get_by_x_y(grid, x, y)
      CalbeGrid.get_is_point_in_bounds(grid, {x, y}) && String.to_integer(value) == String.to_integer(curr_value) + 1
    end)
  end

  defp get_should_halt(_grid, priority_queue, end_point) do
    end_dist = Enum.find(priority_queue, fn {point, _} -> point == end_point end) |> elem(1)

    end_dist != :infinity
  end

  defp calculate_trailhead_score(grid, {trailhead_x, trailhead_y}, all_nines) do
    Enum.reduce(all_nines, 0, fn {x, y}, acc ->

      pq = CalbeGrid.dijkstra(grid, {trailhead_x, trailhead_y}, &get_possible_moves/3, &get_should_halt/3, {x, y}, fn _, _, _ -> 1 end)

      reachable = elem(pq, 0) |> Enum.find(fn {{pqx, pqy}, _v} -> pqx == x && pqy == y end) |> elem(1) != :infinity

      if reachable do
        acc + 1
      else
        acc
      end
    end)
  end

  def part1(input) do
    parsed = get_parsed_input(input)

    all_zeros = CalbeGrid.filter_points(parsed, fn value -> value == "0" end)
    |> Enum.map(fn {coords, _value} -> coords end)

    all_nines = CalbeGrid.filter_points(parsed, fn value -> value == "9" end)
    |> Enum.map(fn {coords, _value} -> coords end)

    Enum.map(all_zeros, fn {x, y} ->
      calculate_trailhead_score(parsed, {x, y}, all_nines)
    end)
    |> Enum.sum()
  end

  defp bfs(grid, {{curr_x, curr_y}, value}, path) do
    possible_moves = [
      {curr_x + 1, curr_y},
      {curr_x - 1, curr_y},
      {curr_x, curr_y + 1},
      {curr_x, curr_y - 1}
    ]
    |> Enum.filter(fn {x, y} ->
      CalbeGrid.get_is_point_in_bounds(grid, {x, y})
      && String.to_integer(
        CalbeGrid.get_by_x_y(grid, x, y)
        |> String.replace(".", "0")
        ) ==
        String.to_integer(value) + 1
    end)

    if Enum.empty?(possible_moves) do
      path
    else
      Enum.reduce(possible_moves, path, fn {x, y}, acc ->
        pt = {{x, y}, CalbeGrid.get_by_x_y(grid, x, y)}
        bfs(grid, pt, acc ++ [pt])
      end)
    end
  end

  def part2(input) do
    parsed = get_parsed_input(input)

    all_zeros = CalbeGrid.filter_points(parsed, fn value -> value == "0" end)

    Enum.map(all_zeros, fn point ->
      bfs(parsed, point, [point])
    end)
    |> List.flatten()
    |> Enum.filter(fn {_, v} -> v == "9" end)
    |> Enum.count()
  end
end
