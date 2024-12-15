defmodule AdventOfCode.Day15 do
  @moduledoc """
  this was very much a challenge and my code is a mess but glad I got it working
  It was not so much difficult as it was daunting the amount of cases I had to handle

  Don't have the energy to clean this up too much, so guess it'll stay messy ha
  """

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    [map, moves] = input
    |> String.split("\n\n", trim: true)

    grid = CalbeGrid.parse(map, "\n", "")

    {
      grid,
      String.replace(moves, "\n", "")
      |> String.split("", trim: true)
    }
  end

  defp find_empty_space_along_path(grid, {x, y}, {mx, my}) do
    cond do
      CalbeGrid.get_by_x_y(grid, x, y) == "#" -> nil
      CalbeGrid.get_by_x_y(grid, x, y) == "." -> {x, y}
      true -> find_empty_space_along_path(grid, {x + mx, y + my}, {mx, my})
    end
  end

  def part1(input) do

    {grid, movements} = get_parsed_input(input)

    CalbeGrid.visualize_grid(grid)

    IO.inspect(movements, label: "movements")

    robot_pos = CalbeGrid.find_point(grid, fn cell -> cell == "@" end)
    |> IO.inspect(label: "robot_pos")

    Enum.reduce(movements, %{
      robot_pos: robot_pos,
      grid: grid
    }, fn move, acc ->
      {robo_x, robo_y} = acc.robot_pos
      grid = acc.grid

      # CalbeGrid.visualize_grid(grid)

      new_robot_pos = case move do
        "^" -> {robo_x, robo_y - 1}
        "v" -> {robo_x, robo_y + 1}
        "<" -> {robo_x - 1, robo_y}
        ">" -> {robo_x + 1, robo_y}
      end

      cond do
        CalbeGrid.get_by_x_y(grid, elem(new_robot_pos, 0), elem(new_robot_pos, 1)) == "." ->
          new_grid = CalbeGrid.set_by_x_y(grid, robo_x, robo_y, ".")
          |> CalbeGrid.set_by_x_y(elem(new_robot_pos, 0), elem(new_robot_pos, 1), "@")

          %{
            robot_pos: new_robot_pos,
            grid: new_grid
          }
        CalbeGrid.get_by_x_y(grid, elem(new_robot_pos, 0), elem(new_robot_pos, 1)) == "#" ->
          acc
        true ->
          # we're moving into a box. We we need to recursively traverse in the direction of the move
          # until we hit a wall or an empty space
          # depending on which, we move all boxes between us and empty or do nothing

          empty_space_along_path = find_empty_space_along_path(grid, new_robot_pos, case move do
            "^" -> {0, -1}
            "v" -> {0, 1}
            "<" -> {-1, 0}
            ">" -> {1, 0}
          end)
          |> IO.inspect(label: "empty_space_along_path")

          if empty_space_along_path == nil do
            acc
          else
            new_grid = CalbeGrid.set_by_x_y(grid, robo_x, robo_y, ".")
            |> CalbeGrid.set_by_x_y(elem(new_robot_pos, 0), elem(new_robot_pos, 1), "@")
            |> CalbeGrid.set_by_x_y(elem(empty_space_along_path, 0), elem(empty_space_along_path, 1), "O")

            %{
              robot_pos: new_robot_pos,
              grid: new_grid
            }
          end

      end

    end)
    |> IO.inspect(label: "final state")
    |> Map.get(:grid)
    |> CalbeGrid.filter_points(fn cell -> cell == "O" end)
    |> IO.inspect(label: "boxes")
    |> Enum.reduce(0, fn {{x, y}, _}, acc -> acc + (y * 100) + x end)


  end

  defp get_parsed_input2(input) do
    [map, moves] = input
    |> String.split("\n\n", trim: true)

    grid = map
      |> String.replace("#", "##")
      |> String.replace("O", "[]")
      |> String.replace(".", "..")
      |> String.replace("@", "@.")
      |> CalbeGrid.parse("\n", "")

    {
      grid,
      String.replace(moves, "\n", "")
      |> String.split("", trim: true)
    }
  end

  defp perform_lateral_box_push(grid, {old_robot_x, old_robot_y}, {empty_x, empty_y}, "<") do
    Enum.reduce(0..abs(old_robot_x - empty_x), grid, fn i, acc ->
      cond do
        i == 0 ->
          IO.inspect("fkn hello?")
          CalbeGrid.set_by_x_y(acc, old_robot_x, old_robot_y, ".")
        i == 1 ->
          CalbeGrid.set_by_x_y(acc, old_robot_x - i, old_robot_y, "@")
        rem(i, 2) == 0 ->
          CalbeGrid.set_by_x_y(acc, old_robot_x - i, old_robot_y, "]")
        true ->
          CalbeGrid.set_by_x_y(acc, old_robot_x - i, old_robot_y, "[")
      end
    end)
  end

  defp perform_lateral_box_push(grid, {old_robot_x, old_robot_y}, {empty_x, empty_y}, ">") do
    Enum.reduce(0..abs(old_robot_x - empty_x), grid, fn i, acc ->
      cond do
        i == 0 ->
          CalbeGrid.set_by_x_y(acc, old_robot_x, old_robot_y, ".")
        i == 1 ->
          CalbeGrid.set_by_x_y(acc, old_robot_x + i, old_robot_y, "@")
        rem(i, 2) == 0 ->
          CalbeGrid.set_by_x_y(acc, old_robot_x + i, old_robot_y, "[")
        true ->
          CalbeGrid.set_by_x_y(acc, old_robot_x + i, old_robot_y, "]")
      end
    end)
  end

  defp bfs(grid, ydir, ylvl, stack) do
    IO.inspect("bfs")
    IO.inspect(stack, label: "stack")
    # first, ensure we have full boxes at our current level
    this_level = Enum.filter(stack, fn {{_x, y}, _v} -> y == ylvl end)

    {{lx, _ly}, leftmost_val} = this_level
    |> Enum.min_by(fn {{x, _y}, _v} -> x end)

    {{rx, _ry}, rightmost_val} = this_level
    |> Enum.max_by(fn {{x, _y}, _v} -> x end)

    new_stack = cond do
      leftmost_val == "]" && rightmost_val == "[" ->
        # we need to add one left of leftmost and one right of rightmost to stack
        stack ++ [CalbeGrid.get_point_by_x_y(grid, lx - 1, ylvl), CalbeGrid.get_point_by_x_y(grid, rx + 1, ylvl)]
      leftmost_val == "]" ->
        stack ++ [CalbeGrid.get_point_by_x_y(grid, lx - 1, ylvl)]
      rightmost_val == "[" ->
        stack ++ [CalbeGrid.get_point_by_x_y(grid, rx + 1, ylvl)]
      true ->
        stack
    end

    this_level_updated = Enum.filter(new_stack, fn {{_x, y}, _v} -> y == ylvl end)
    |> IO.inspect(label: "this_level_updated")

    # now we need to look in ydir direction from every entry at this level
    # and add any boxes we find to the stack
    stack_with_next_lvl = Enum.reduce(this_level_updated, new_stack, fn {{x, y}, _v}, acc ->
      step = CalbeGrid.get_point_by_x_y(grid, x, y + ydir)
      |> IO.inspect(label: "step")
      stepval = elem(step, 1)
      case stepval do
        "[" -> acc ++ [step]
        "]" -> acc ++ [step]
        _ -> acc
      end
    end)

    # if we added none, we're done
    if Enum.count(stack_with_next_lvl) == Enum.count(new_stack) do
      stack_with_next_lvl
    else
      bfs(grid, ydir, ylvl + ydir, stack_with_next_lvl)
    end

  end

  defp get_box_stack(grid, {old_robot_x, old_robot_y}, move) do
    IO.inspect("get_box_stack")
    # let's bfs in our move direction to fill out our potential stack of boxes to push
    ydir = case move do
      "^" -> -1
      "v" -> 1
    end
    boxes = bfs(grid, ydir, old_robot_y + ydir, [CalbeGrid.get_point_by_x_y(grid, old_robot_x, old_robot_y + ydir)])
    |> IO.inspect(label: "boxes")
  end

  defp get_can_stack_move_in_dir(grid, stack, move) do
    ydir = case move do
      "^" -> -1
      "v" -> 1
    end

    Enum.all?(stack, fn {{x, y}, _v} ->
      CalbeGrid.get_by_x_y(grid, x, y + ydir) != "#"
    end)
  end

  defp perform_vertical_box_push(grid, stack, move, {old_robot_x, old_robot_y}) do
    # for all cells in stack, set their current loc to "." and new loc to current value.
    # we need to first sort them by the direction we're moving
    # if up, do highest y first, if down, do lowest y first

    ydir = case move do
      "^" -> -1
      "v" -> 1
    end

    sorted_stack = if ydir == -1 do
      Enum.sort(stack, fn {{_x1, y1}, _v1}, {{_x2, y2}, _v2} -> y1 < y2 end)
    else
      Enum.sort(stack, fn {{_x1, y1}, _v1}, {{_x2, y2}, _v2} -> y1 > y2 end)
    end

    Enum.reduce(sorted_stack, grid, fn {{x, y}, val}, acc ->
      CalbeGrid.set_by_x_y(acc, x, y, ".")
      |> CalbeGrid.set_by_x_y(x, y + ydir, val)
    end)
    |> CalbeGrid.set_by_x_y(old_robot_x, old_robot_y, ".")
    |> CalbeGrid.set_by_x_y(old_robot_x, old_robot_y + ydir, "@")


  end

  def part2(input) do

    {grid, movements} = get_parsed_input2(input)

    CalbeGrid.visualize_grid(grid)

    IO.inspect(movements, label: "movements")

    robot_pos = CalbeGrid.find_point(grid, fn cell -> cell == "@" end)
    |> IO.inspect(label: "robot_pos")

    Enum.reduce(movements, %{
      robot_pos: robot_pos,
      grid: grid
    }, fn move, acc ->
      {robo_x, robo_y} = acc.robot_pos
      grid = acc.grid

      # CalbeGrid.visualize_grid(grid)

      new_robot_pos = case move do
        "^" -> {robo_x, robo_y - 1}
        "v" -> {robo_x, robo_y + 1}
        "<" -> {robo_x - 1, robo_y}
        ">" -> {robo_x + 1, robo_y}
      end

      cond do
        CalbeGrid.get_by_x_y(grid, elem(new_robot_pos, 0), elem(new_robot_pos, 1)) == "." ->
          new_grid = CalbeGrid.set_by_x_y(grid, robo_x, robo_y, ".")
          |> CalbeGrid.set_by_x_y(elem(new_robot_pos, 0), elem(new_robot_pos, 1), "@")

          %{
            robot_pos: new_robot_pos,
            grid: new_grid
          }
        CalbeGrid.get_by_x_y(grid, elem(new_robot_pos, 0), elem(new_robot_pos, 1)) == "#" ->
          acc
        true ->

          # BRAIN DUMP

          # we're moving into a box. We we need to recursively traverse in the direction of the move
          # until we hit a wall or an empty space
          # depending on which, we move all boxes between us and empty or do nothing
          # the difference this time is that we need to also cascade outward in case
          # misaligned boxes are in the way, in which case we push them too.
          # this is really more like flood filling a shape we're against
          # and we need to basically identify the box shape we're pushing, only
          # in the direction moving away from ourselves, and only boxes that
          # "lay on" our box, if we were going up.
          # then we decide if anything is stopping that push.
          # if so, we stop, if not, we push all of those boxes by one
          # I also just realized this only matters in left and right directions
          # as the boxes are split in that way (vert) so for instances of up and down


          cond do
            move == "^" or move == "v" ->
              IO.inspect("vertical push detected for move #{move}")
              stack = get_box_stack(grid, acc.robot_pos, move)

              possible = get_can_stack_move_in_dir(grid, stack, move)
              |> IO.inspect(label: "possible")

              if possible == false do
                acc
              else
                new_grid = perform_vertical_box_push(grid, stack, move, acc.robot_pos)

                %{
                  robot_pos: new_robot_pos,
                  grid: new_grid
                }
              end
            true ->
              empty_space_along_path = find_empty_space_along_path(grid, new_robot_pos, case move do
                "<" -> {-1, 0}
                ">" -> {1, 0}
              end)
              |> IO.inspect(label: "empty_space_along_path")

              if empty_space_along_path == nil do
                acc
              else

                new_grid = perform_lateral_box_push(grid, acc.robot_pos, empty_space_along_path, move)

                %{
                  robot_pos: new_robot_pos,
                  grid: new_grid
                }
              end
          end

      end

    end)
    |> IO.inspect(label: "final state")
    |> Map.get(:grid)
    |> CalbeGrid.visualize_grid()
    |> CalbeGrid.filter_points(fn cell -> cell == "[" end)
    |> IO.inspect(label: "boxes")
    |> Enum.reduce(0, fn {{x, y}, _}, acc -> acc + (y * 100) + x end)

  end
end
