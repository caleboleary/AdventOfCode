defmodule AdventOfCode.Day18 do

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    positions = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ",", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)

    grid_dims = if String.split(input, "\n", trim: true) |> List.first() == "5,4" do
      7
    else
      71
    end

    text_row = List.duplicate(".", grid_dims)
    |> Enum.join("")

    text_grid = List.duplicate(text_row, grid_dims)
    |> Enum.join("\n")

    grid = CalbeGrid.parse(text_grid, "\n", "")

    {grid, positions, grid_dims}
  end

  defp get_viable_moves(grid, {x, y}, _) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Enum.filter(fn {x, y} ->
      CalbeGrid.get_by_x_y(grid, x, y) == "."
    end)
  end

  defp get_should_halt(grid, pq, end_point) do
    Enum.find(pq, fn {point, _} -> point == end_point end) |> elem(1) != :infinity
  end

  defp get_weight(_grid, _n, _cn, _prds) do
    1
  end

  def part1(input) do
    {empty_grid, positions, dims} = get_parsed_input(input)


    positions_subset = if dims == 7 do
      Enum.take(positions, 12)
    else
      Enum.take(positions, 1024)
    end

    grid = Enum.reduce(positions_subset, empty_grid, fn [x, y], acc ->
      Map.put(acc, {x, y}, "#")
    end)
    |> CalbeGrid.visualize_grid()

    start_pos = {0, 0}
    end_pos = {dims - 1, dims - 1}

    shortest_path = CalbeGrid.dijkstra(grid, start_pos, &get_viable_moves/3, &get_should_halt/3, end_pos, &get_weight/4)
    # |> IO.inspect([label: "shortest_path", charlists: :as_lists])
    |> elem(0)
    |> Enum.find(fn {point, _} -> point == end_pos end)
    |> elem(1)

  end

  defp get_grid_with_positions(grid, positions) do
    Enum.reduce(positions, grid, fn [x, y], acc ->
      Map.put(acc, {x, y}, "#")
    end)
  end

  defp get_is_path_obstructed(grid, start_pos, end_pos) do
    CalbeGrid.dijkstra(grid, start_pos, &get_viable_moves/3, &get_should_halt/3, end_pos, &get_weight/4)
    |> elem(0)
    |> Enum.find(fn {point, _} -> point == end_pos end)
    |> elem(1) == :infinity
  end

  def part2(input) do

    {empty_grid, positions, dims} = get_parsed_input(input)


    positions_subset = if dims == 7 do
      Enum.take(positions, 12)
    else
      Enum.take(positions, 1024)
    end

    grid = Enum.reduce(positions_subset, empty_grid, fn [x, y], acc ->
      Map.put(acc, {x, y}, "#")
    end)
    |> CalbeGrid.visualize_grid()

    start_pos = {0, 0}
    end_pos = {dims - 1, dims - 1}

    remaining_positions = if dims == 7 do
      Enum.drop(positions, 12)
    else
      Enum.drop(positions, 1024)
    end

    remaining_positions_len = Enum.count(remaining_positions)

    # binary search through the remaining positions
    # we're looking for the lowest value that blocks the path
    half = round(remaining_positions_len / 2)
    |> IO.inspect([label: "half"])

    Enum.reduce_while(1..500, half, fn index, acc ->
      IO.inspect("taking a look at position #{acc} of #{remaining_positions_len} (#{Enum.at(remaining_positions, acc) |> Enum.join(",")})")
      curr = Enum.at(remaining_positions, acc)
      prev = Enum.at(remaining_positions, acc - 1)

      curr_obstructed = get_grid_with_positions(grid, Enum.take(remaining_positions, acc)) |> get_is_path_obstructed(start_pos, end_pos)
      prev_obstructed = get_grid_with_positions(grid, Enum.take(remaining_positions, acc - 1)) |> get_is_path_obstructed(start_pos, end_pos)

      new_half = max(1, round(remaining_positions_len / Integer.pow(2, index + 1)))
      |> IO.inspect([label: "new_half"])

      IO.inspect([curr_obstructed: curr_obstructed, prev_obstructed: prev_obstructed])

      cond do
        curr_obstructed && !prev_obstructed ->
          {:halt, "#{prev |> Enum.at(0)},#{prev |> Enum.at(1)}"}

        curr_obstructed && prev_obstructed ->
          # Both obstructed - need to go left to find first obstruction
          {:cont, acc - new_half}

        !curr_obstructed && !prev_obstructed ->
          # Neither obstructed - need to go right to find obstruction
          {:cont, acc + new_half}

        true ->
          {:cont, acc}
      end

    end)


  end
end
