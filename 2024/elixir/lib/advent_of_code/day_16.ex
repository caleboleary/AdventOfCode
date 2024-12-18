defmodule AdventOfCode.Day16 do

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    Helpers.CalbeGrid.parse(input, "\n", "")
    |> CalbeGrid.visualize_grid()
  end

  defp get_possible_moves(grid, {curr_x, curr_y}, _) do

    potential_coords = [
      {curr_x + 1, curr_y},
      {curr_x - 1, curr_y},
      {curr_x, curr_y + 1},
      {curr_x, curr_y - 1}
    ]

    Enum.filter(potential_coords, fn {x, y} ->
      CalbeGrid.get_by_x_y(grid, x, y) == "." || CalbeGrid.get_by_x_y(grid, x, y) == "E"
    end)
  end

  defp get_should_halt(_grid, priority_queue, end_point) do
    end_dist = Enum.find(priority_queue, fn {point, _} -> point == end_point end) |> elem(1)

    end_dist != :infinity
  end

  defp get_weight(grid, neighbor, current_node, preds) do
    prev_node = Map.get(preds, current_node)

    # IO.inspect(Enum.at(preds, 0), label: "preds0")
    # IO.inspect(Enum.at(preds, -1), label: "preds-1")
    # IO.inspect(current_node, label: "current_node")
    # IO.inspect(neighbor, label: "neighbor")

    {cx, cy} = current_node
    {nx, ny} = neighbor

    if prev_node do
        {px, py} = prev_node
        prev_dir = {cx - px, cy - py}
        new_dir = {nx - cx, ny - cy}

        if prev_dir == new_dir do
            1
        else
            1001
        end
    else
        # first move, start facing east (+1 in x dir)
        case {nx - cx, ny - cy} do
            {1, 0} -> 1
            _ -> 1001
        end
    end
  end

  def part1(input) do

    parsed = get_parsed_input(input)
    start_pos = CalbeGrid.find_point(parsed, fn cell -> cell == "S" end)
    |> IO.inspect(label: "start_pos")
    end_pos = CalbeGrid.find_point(parsed, fn cell -> cell == "E" end)
    |> IO.inspect(label: "end_pos")

    start_dir = ">"

    # dijkstra(grid, {start_x, start_y}, get_viable_moves, get_should_halt, end_point, get_weight)
    shortest_path = CalbeGrid.dijkstra(parsed, start_pos, &get_possible_moves/3, &get_should_halt/3, end_pos, &get_weight/4)
    # |> IO.inspect(label: "shortest_path", limit: :infinity)
    |> elem(0)
    |> Enum.find(fn {{x, y}, _} -> x == elem(end_pos, 0) && y == elem(end_pos, 1) end)
    |> IO.inspect(label: "shortest_path_end")
    |> elem(1)

  end

  defp dfs(grid, {x, y}, end_pos, shortest_path_cost, path_cost, path, lens_list) do
    # IO.inspect(path, label: "path")
    # IO.inspect(path_cost, label: "path_cost")
    prev = Enum.at(path, -1)

    prev_best = Enum.find(lens_list, fn {{px, py}, _} -> px == x && py == y end)

    if path_cost > shortest_path_cost || prev_best < path_cost do
      # if we exceed shortest full path len, stop, or if we know we can get to this point faster
      []
    else
      cell = CalbeGrid.get_by_x_y(grid, x, y)
      new_path = path ++ [{x, y}]

      prevprev = Enum.at(new_path, -3)

      new_path_cost = if prev && prevprev do
        prev_dir = {elem(prev, 0) - elem(prevprev, 0), elem(prev, 1) - elem(prevprev, 1)}
        new_dir = {x - elem(prev, 0), y - elem(prev, 1)}

        path_cost + if prev_dir == new_dir do 1 else 1001 end
      else
        # determine if we've moved to the right of the start position
        case {x - elem(prev, 0), y - elem(prev, 1)} do
          {1, 0} -> path_cost + 1
          _ -> path_cost + 1001
        end
      end


      if cell == "E" do
        IO.inspect("reached end")
        IO.inspect(new_path_cost, label: "new_path_cost")
      end

      if cell == "E" && new_path_cost == shortest_path_cost do
        IO.inspect("ding ding ding")
        new_path
      else
        potential_coords = [
          {x + 1, y},
          {x - 1, y},
          {x, y + 1},
          {x, y - 1}
        ]

        Enum.reduce(potential_coords, [], fn {x2, y2}, acc ->
          if (CalbeGrid.get_by_x_y(grid, x2, y2) == "." || CalbeGrid.get_by_x_y(grid, x2, y2) == "E")
          && !Enum.member?(new_path, {x2, y2})
          do
            dfs(grid, {x2, y2}, end_pos, shortest_path_cost, new_path_cost, new_path, lens_list) ++ acc
          else
            acc
          end
        end)
      end
    end
  end

  defp find_all_paths_with_cost(grid, start_pos, end_pos, shortest_path_cost, lens_list) do
    # walk all paths, bail out if the path cost exceeds the shortest path cost
    # return all paths that have the same cost as the shortest path
    IO.inspect(shortest_path_cost, label: "shortest_path_cost")

    {sx, sy} = start_pos

    possible_moves_from_start = [
      {sx + 1, sy},
      {sx - 1, sy},
      {sx, sy + 1},
      {sx, sy - 1}
    ]

    Enum.reduce(possible_moves_from_start, [], fn {x, y}, acc ->
      if CalbeGrid.get_by_x_y(grid, x, y) == "." do
        IO.inspect({x, y}, label: "start_pos")
        dfs(grid, {x, y}, end_pos, shortest_path_cost, 0, [start_pos], lens_list) ++ acc
      else
        acc
      end
    end)

  end

  def part2(input) do
    parsed = get_parsed_input(input)
    start_pos = CalbeGrid.find_point(parsed, fn cell -> cell == "S" end)
    |> IO.inspect(label: "start_pos")
    end_pos = CalbeGrid.find_point(parsed, fn cell -> cell == "E" end)
    |> IO.inspect(label: "end_pos")

    start_dir = ">"

    # dijkstra(grid, {start_x, start_y}, get_viable_moves, get_should_halt, end_point, get_weight)
    results = CalbeGrid.dijkstra(parsed, start_pos, &get_possible_moves/3, &get_should_halt/3, end_pos, &get_weight/4)
    |> IO.inspect(label: "results", limit: :infinity)

    lens_list = results |> elem(0)


    shortest_path = lens_list
    |> Enum.find(fn {{x, y}, _} -> x == elem(end_pos, 0) && y == elem(end_pos, 1) end)
    |> IO.inspect(label: "shortest_path_end")

    shortest_len = elem(shortest_path, 1)


    find_all_paths_with_cost(parsed, start_pos, end_pos, shortest_len, lens_list)
    |> Enum.uniq()
    |> Enum.count()
  end
end
