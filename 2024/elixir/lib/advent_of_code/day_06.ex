defmodule AdventOfCode.Day06 do
  @moduledoc """
  Well, this one was fun. I thought, as I did the first part, that I should do the work to make
  the guard slide in a straight line per iteration to their next turn rather than single step
  and I didn't.

  That came back to bite me in p2 as this solution has some perf issues. It takes several minutes
  to run. I tihnk one thing to help would be what I mentioned above.

  I think you could also store the locations where the guards exit the maps and then the entire path
  that led them there in other iterations, then if you stumble onto any of those paths, and you
  aren't along that future path, you know you also won't cause a loop.

  However, my most anticipated book of the year "Wind and Truth" by brando sando just dropped
  so I'm not going to worry about my perf =]
  """

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    input |>
    CalbeGrid.parse("\n", "")
    |> CalbeGrid.visualize_grid()
  end

  defp update_grid(grid, {ox, oy}, {nx, ny}, new_guard_cell) do
    grid
    |> CalbeGrid.set_by_x_y(ox, oy, ".")
    |> CalbeGrid.set_by_x_y(nx, ny, new_guard_cell)
  end

  defp advance_guard(grid, {x, y}) do
    guard = CalbeGrid.get_by_x_y(grid, x, y)

    cond do
      guard == "^" ->
        if y == 0 do
          {
            grid,
            nil
          }
        else
          if CalbeGrid.get_by_x_y(grid, x, y - 1) == "#" do
            {
              update_grid(grid, {x, y}, {x, y}, ">"),
              {x, y}
            }
          else
            {
              update_grid(grid, {x, y}, {x, y - 1}, "^"),
              {x, y - 1}
            }
          end
        end
      guard == "v" ->
        if y == CalbeGrid.get_grid_len(grid) - 1 do
          {
            grid,
            nil
          }
        else
          if CalbeGrid.get_by_x_y(grid, x, y + 1) == "#" do
            {
              update_grid(grid, {x, y}, {x, y}, "<"),
              {x, y}
            }
          else
            {
              update_grid(grid, {x, y}, {x, y + 1}, "v"),
              {x, y + 1}
            }
          end
        end
      guard == "<" ->
        if x == 0 do
          {
            grid,
            nil
          }
        else
          if CalbeGrid.get_by_x_y(grid, x - 1, y) == "#" do
            {
              update_grid(grid, {x, y}, {x, y}, "^"),
              {x, y}
            }
          else
            {
              update_grid(grid, {x, y}, {x - 1, y}, "<"),
              {x - 1, y}
            }
          end
        end
      guard == ">" ->
        if x == CalbeGrid.get_grid_width(grid) - 1 do
          {
            grid,
            nil
          }
        else
          if CalbeGrid.get_by_x_y(grid, x + 1, y) == "#" do
            {
              update_grid(grid, {x, y}, {x, y}, "v"),
              {x, y}
            }
          else
            {
              update_grid(grid, {x, y}, {x + 1, y}, ">"),
              {x + 1, y}
            }
          end
        end
    end
  end

  def part1(input) do

    grid = get_parsed_input(input)

    guard_pos = CalbeGrid.find_point(grid, fn cell -> cell == "^" end)

    limit = 100000

    Enum.reduce_while(0..limit, %{
      visited_points: MapSet.new(),
      grid: grid,
      guard_pos: guard_pos
    }, fn i, acc ->
      if i == limit do
        {:halt, acc}
      else

        {new_grid, new_guard_pos} = advance_guard(acc.grid, acc.guard_pos)

        new_acc = %{
          visited_points: MapSet.put(acc.visited_points, acc.guard_pos),
          grid: new_grid,
          guard_pos: new_guard_pos
        }

        if new_guard_pos != nil do
          {:cont, new_acc}
        else
          {:halt, new_acc}
        end
      end
    end)
    |> Map.get(:visited_points)
    |> MapSet.size()

  end

  defp check_if_setup_results_in_loop(grid, limit) do

    guard_pos = CalbeGrid.find_point(grid, fn cell -> cell == "^" end)

    Enum.reduce_while(0..limit, %{
      visited_points: MapSet.new(),
      grid: grid,
      guard_pos: guard_pos
    }, fn i, acc ->
      if i == limit do
        {:halt, acc}
      else

        {new_grid, new_guard_pos} = advance_guard(acc.grid, acc.guard_pos)

        new_hash = case new_guard_pos do
          nil -> :exit
          pos -> {pos, CalbeGrid.get_by_x_y(new_grid, elem(pos, 0), elem(pos, 1))}
        end

        new_acc = %{
          visited_points: MapSet.put(acc.visited_points, new_hash),
          grid: new_grid,
          guard_pos: new_guard_pos
        }

        cond do
          new_guard_pos == nil ->
            {:halt, false}
          MapSet.member?(acc.visited_points, new_hash) ->
            {:halt, true}
          i > limit - 1 ->
            IO.inspect("---------------------------LIMIT REACHED---------------------------")
            {:halt, %{
              loops: false,
              visited_points: acc.visited_points,
            }}
          true ->
            {:cont, new_acc}
        end
      end
    end)

  end

  def part2(input) do

    grid = get_parsed_input(input)

    guard_pos = CalbeGrid.find_point(grid, fn cell -> cell == "^" end)

    possible_obstruction_points = Map.filter(grid, fn {key, value} ->
      value != "#" && value != "^" && key != :util
    end)
    |> Map.keys()

    total = Enum.count(possible_obstruction_points)

    loop_obstruction_points = Enum.with_index(possible_obstruction_points)
    |> Enum.map(fn {{x, y}, i} ->
      IO.puts("checking #{i} of #{total} (#{i/total * 100}%)")

      mod_grid = CalbeGrid.set_by_x_y(grid, x, y, "#")
      check_if_setup_results_in_loop(mod_grid, 50000)
    end)
    |> Enum.filter(fn x -> x == true end)
    |> Enum.count()

  end
end
