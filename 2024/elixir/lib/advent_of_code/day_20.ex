defmodule AdventOfCode.Day20 do

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    input
    |> CalbeGrid.parse("\n", "")
    |> CalbeGrid.visualize_grid()
  end

  defp dfs(grid, {x, y}, visited) do
    visited = visited ++ [{x, y}]
    neighbors = [
      {x, y + 1},
      {x, y - 1},
      {x + 1, y},
      {x - 1, y}
    ]
    |> IO.inspect([label: "neighbors", charlists: :as_lists])

    next = Enum.find(neighbors, fn n ->
      !Enum.member?(visited, n) and CalbeGrid.get_by_x_y(grid, elem(n, 0), elem(n, 1)) != "#"
    end)
    |> IO.inspect([label: "next", charlists: :as_lists])

    {nx, ny} = next

    if CalbeGrid.get_by_x_y(grid, nx, ny) == "E" do
      visited ++ [{nx, ny}]
    else
      dfs(grid, {nx, ny}, visited)
    end
  end

  defp get_intended_path(grid, start_pos, end_pos) do
    dfs(grid, start_pos, [])
  end

  def part1(input) do
    grid = get_parsed_input(input)

    start_pos = CalbeGrid.find_point(grid, fn cell -> cell == "S" end)
    end_pos = CalbeGrid.find_point(grid, fn cell -> cell == "E" end)

    intended_path = get_intended_path(grid, start_pos, end_pos)
    |> IO.inspect([label: "intended_path", charlists: :as_lists])

    potential_cheats = Enum.filter(grid, fn {a, b} -> a != :util end)
    |> Enum.map(fn {{x, y}, cell} ->
      nonwall_neighbors = [
        {x, y + 1},
        {x, y - 1},
        {x + 1, y},
        {x - 1, y}
      ]
      |> Enum.filter(fn {pnx, pny} ->
        cell = CalbeGrid.get_by_x_y(grid, pnx, pny)
        cell != "#" && cell != nil
      end)

      nonwall_neighbors_count = nonwall_neighbors
      |> length()

      if cell == "#" and nonwall_neighbors_count > 1 do
        %{entry: {x, y}, nonwall_neighbors: nonwall_neighbors}
      else
        nil
      end
    end)
    |> Enum.filter(fn x -> x != nil end)
    |> IO.inspect([label: "potential_cheats", charlists: :as_lists])

    # for each potential cheat, snip it out of intended path and count length
    cheat_saved = Enum.map(potential_cheats, fn %{entry: {x, y}, nonwall_neighbors: nonwall_neighbors} ->
      IO.inspect(nonwall_neighbors, [label: "nonwall_neighbors", charlists: :as_lists])
      nonwall_indexes = Enum.map(nonwall_neighbors, fn {nx, ny} ->
        intended_path
        |> Enum.find_index(fn {ix, iy} -> ix == nx and iy == ny end)
      end)
      |> Enum.sort()
      |> IO.inspect([label: "nonwall_indexes", charlists: :as_lists])

      # (Enum.slice(intended_path, 0, Enum.at(nonwall_indexes, 0) + 1) ++ Enum.slice(intended_path, Enum.at(nonwall_indexes, 1), length(intended_path)))
      # |> IO.inspect([label: "snipped_path", charlists: :as_lists])
      # |> length()
      Enum.at(nonwall_indexes, 1) - Enum.at(nonwall_indexes, 0) - 2
    end)
    |> IO.inspect([label: "cheat_saved", charlists: :as_lists])
    |> Enum.filter(fn x -> x >= 100 end)
    |> length()

  end

  defp bfs(grid, {source_x, source_y}, intended_path, reachable_wall_positions, reachable_future_path_positions, depth) do
    # IO.inspect("bfs")
    # IO.inspect(length(reachable_wall_positions), [label: "reachable_wall_positions"])
    # IO.inspect(length(reachable_future_path_positions), [label: "reachable_future_path_positions"])
    # IO.inspect(depth, [label: "depth"])

    source_index = Enum.find_index(intended_path, fn {x, y} -> x == source_x and y == source_y end)

    {new_wall_positions, new_path_positions} = Enum.map(reachable_wall_positions, fn {x, y} ->
      # for each wall position, find all reachable future path positions
      # and add them to the reachable_future_path_positions
      # and add the wall position to the reachable_future_path_positions

      neighbors = [
        {x, y + 1},
        {x, y - 1},
        {x + 1, y},
        {x - 1, y}
      ]

      wall_neighbors = Enum.filter(neighbors, fn {nx, ny} ->
        CalbeGrid.get_by_x_y(grid, nx, ny) == "#"
      end)

      path_neighbors = Enum.filter(neighbors, fn {nx, ny} ->
        cell = CalbeGrid.get_by_x_y(grid, nx, ny)
        cell == "." || cell == "E"
        # don't think we need to track S here as never future
      end)

      unfound_wall_neighbors = Enum.filter(wall_neighbors, fn {nx, ny} ->
        !Enum.member?(reachable_wall_positions, {nx, ny})
      end)

      unfound_path_neighbors = Enum.filter(path_neighbors, fn {nx, ny} ->
        !Enum.member?(reachable_future_path_positions, {nx, ny})
      end)

      future_path_positions = Enum.filter(unfound_path_neighbors, fn {nx, ny} ->
        index = Enum.find_index(intended_path, fn {x, y} -> x == nx and y == ny end)
        index != nil and index > source_index
      end)

      {unfound_wall_neighbors, future_path_positions}
    end)
    |> Enum.reduce({[], []}, fn {wall_positions, future_path_positions}, {new_wall_positions, new_future_path_positions} ->
      {wall_positions ++ new_wall_positions, future_path_positions ++ new_future_path_positions}
    end)

    # IO.inspect(new_wall_positions, [label: "new_wall_positions", charlists: :as_lists])
    # IO.inspect(new_path_positions, [label: "new_path_positions", charlists: :as_lists])

    new_reachable_wall_positions = reachable_wall_positions ++ Enum.uniq(new_wall_positions)
    new_reachable_future_path_positions = reachable_future_path_positions ++ Enum.uniq(new_path_positions)

    if depth >= 20 do
      new_reachable_future_path_positions
    else
      bfs(grid, {source_x, source_y}, intended_path, new_reachable_wall_positions, new_reachable_future_path_positions, depth + 1)
    end

  end

  defp get_all_20step_cheats_starting_at(grid, {x, y}, intended_path) do
    first_neighbors = [
      {x, y + 1},
      {x, y - 1},
      {x + 1, y},
      {x - 1, y}
    ]
    |> Enum.filter(fn {nx, ny} ->
      CalbeGrid.get_by_x_y(grid, nx, ny) == "#"
    end)


    bfs(grid, {x, y}, intended_path, [{x, y}], first_neighbors, 0)
  end

  # def part2(input) do
  #   # thoughts
  #   # for this one, I'd say we just observe every step along the path, and search out from there
  #   # bfs probably, crawl through walls up to 20, finding all reachable exits
  #   # and find the distinct exit points farther in the path we can reach from there.
  #   # that will give us all of the new long cheats, and we can calc out the lengths just the same
  #   grid = get_parsed_input(input)

  #   start_pos = CalbeGrid.find_point(grid, fn cell -> cell == "S" end)
  #   end_pos = CalbeGrid.find_point(grid, fn cell -> cell == "E" end)

  #   intended_path = get_intended_path(grid, start_pos, end_pos)
  #   |> IO.inspect([label: "intended_path", charlists: :as_lists])

  #   potential_cheats = Enum.reduce(intended_path, [], fn {x, y}, acc ->
  #     IO.inspect({x, y}, [label: "x, y"])
  #     get_all_20step_cheats_starting_at(grid, {x, y}, intended_path)
  #     |> IO.inspect([label: "cheats", charlists: :as_lists])
  #     |> Enum.map(fn out -> {{x, y}, out} end)

  #     throw :yoooo
  #   end)
  #   |> List.flatten()
  #   |> Enum.filter(fn {a, b} -> a != b end)
  #   |> IO.inspect([label: "potential_cheats", charlists: :as_lists])

  #   cheat_saved = Enum.map(potential_cheats, fn {{ix, iy}, {ox, oy}} ->
  #     IO.inspect({ix, iy}, [label: "ix, iy"])
  #     IO.inspect({ox, oy}, [label: "ox, oy"])
  #     start_index = Enum.find_index(intended_path, fn {x, y} -> x == ix and y == iy end)
  #     |> IO.inspect([label: "start_index", charlists: :as_lists])
  #     end_index = Enum.find_index(intended_path, fn {x, y} -> x == ox and y == oy end)
  #     |> IO.inspect([label: "end_index", charlists: :as_lists])

  #     throw :yoooooo

  #     if start_index != nil and end_index != nil do
  #       end_index - start_index
  #     else
  #       0
  #     end

  #   end)
  #   |> IO.inspect([label: "cheat_saved", charlists: :as_lists])
  #   |> Enum.filter(fn x -> x >= 70 end)
  #   |> IO.inspect([label: "cheat_saved", charlists: :as_lists])

  # end

  def part2(input) do
    # just had another thought, maybe no searching is needed and we can just use manhattan distance
    # I think this only works if you can enter and exit walls. If you can't, then you need to search like above

    grid = get_parsed_input(input)

      start_pos = CalbeGrid.find_point(grid, fn cell -> cell == "S" end)
      end_pos = CalbeGrid.find_point(grid, fn cell -> cell == "E" end)

      intended_path = get_intended_path(grid, start_pos, end_pos)
      |> IO.inspect([label: "intended_path", charlists: :as_lists])

      intended_len = length(intended_path)

      # for each point in path, create a "cheat" starting there and ending at all points within 20 distance
      potential_cheats = Enum.reduce(intended_path, [], fn {x, y}, acc ->
        within_20 = Enum.filter(intended_path, fn {nx, ny} ->
          dist = abs(x - nx) + abs(y - ny)

          dist <= 20 && dist > 0
        end)

        incl_src = Enum.map(within_20, fn {ox, oy} ->
          dist = abs(x - ox) + abs(y - oy)
          {{x, y}, {ox, oy}, dist}
        end)

        acc ++ incl_src
      end)
      |> IO.inspect([label: "potential_cheats", charlists: :as_lists])

      cheat_saved = Enum.map(potential_cheats, fn {{ix, iy}, {ox, oy}, dist} ->
        start_index = Enum.find_index(intended_path, fn {x, y} -> x == ix and y == iy end)
        end_index = Enum.find_index(intended_path, fn {x, y} -> x == ox and y == oy end)

        if start_index != nil and end_index != nil do
          end_index - start_index - dist
        else
          0
        end

      end)
      # |> Enum.sort()
      # |> Enum.reverse()
      |> Enum.filter(fn x -> x >= 100 end)
      |> length()
  end
end
