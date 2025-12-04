defmodule AdventOfCode.Day04 do
  alias Helpers.CalbeGrid

  def part1(input) do
    grid = CalbeGrid.parse(input, "\n", "")
    # |> CalbeGrid.visualize_grid()

    len = CalbeGrid.get_grid_len(grid)
    width = CalbeGrid.get_grid_width(grid)

    Enum.reduce(0..(len - 1), 0, fn curr_row, acc_row ->
      Enum.reduce(0..(width - 1), acc_row, fn curr_col, acc_col ->
        cell = CalbeGrid.get_by_x_y(grid, curr_col, curr_row)
        if cell == "@" do

          eight_adjacent_values = [
            CalbeGrid.get_by_x_y(grid, curr_col - 1, curr_row - 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col, curr_row - 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col + 1, curr_row - 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col - 1, curr_row, "."),
            CalbeGrid.get_by_x_y(grid, curr_col + 1, curr_row, "."),
            CalbeGrid.get_by_x_y(grid, curr_col - 1, curr_row + 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col, curr_row + 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col + 1, curr_row + 1, ".")
          ]

          if (Enum.filter(eight_adjacent_values, fn v -> v == "@" end) |> length()) < 4 do
            acc_col + 1
          else
            acc_col
          end
        else
          acc_col
        end
      end)
    end)
  end

  defp get_moveable_rolls_positions(grid) do

    len = CalbeGrid.get_grid_len(grid)
    width = CalbeGrid.get_grid_width(grid)

    Enum.reduce(0..(len - 1), [], fn curr_row, acc_row ->
      Enum.reduce(0..(width - 1), acc_row, fn curr_col, acc_col ->
        cell = CalbeGrid.get_by_x_y(grid, curr_col, curr_row)
        if cell == "@" do

          eight_adjacent_values = [
            CalbeGrid.get_by_x_y(grid, curr_col - 1, curr_row - 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col, curr_row - 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col + 1, curr_row - 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col - 1, curr_row, "."),
            CalbeGrid.get_by_x_y(grid, curr_col + 1, curr_row, "."),
            CalbeGrid.get_by_x_y(grid, curr_col - 1, curr_row + 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col, curr_row + 1, "."),
            CalbeGrid.get_by_x_y(grid, curr_col + 1, curr_row + 1, ".")
          ]

          if (Enum.filter(eight_adjacent_values, fn v -> v == "@" end) |> length()) < 4 do
            acc_col ++ [{curr_col, curr_row}]
          else
            acc_col
          end
        else
          acc_col
        end
      end)
    end)

  end

  def part2(input) do
    grid = CalbeGrid.parse(input, "\n", "")
    # |> CalbeGrid.visualize_grid()

    Enum.reduce_while(1..10000, {grid, []}, fn _curr, {acc_grid, removed_counts} ->

      moveable_rolls_positions = get_moveable_rolls_positions(acc_grid)

      if (moveable_rolls_positions |> length()) == 0 do
        {:halt, removed_counts |> Enum.sum()}
      else
        new_grid = Enum.reduce(moveable_rolls_positions, acc_grid, fn {x, y}, new_grid_acc ->
          CalbeGrid.set_by_x_y(new_grid_acc, x, y, ".")
        end)

        {:cont, {new_grid, removed_counts ++ [length(moveable_rolls_positions)]}}
      end
    end)

  end
end
