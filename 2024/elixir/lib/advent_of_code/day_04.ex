defmodule AdventOfCode.Day04 do
  @moduledoc """
  Stealing the idea of a AOC journal from Steven who stole it from Cody

  This one was pretty fun and *should* have been easier for me because I brought my grid tools forward from last year
  but I got hung up on some stupid mistakes that took me a while to debug because I didn't do any nice visualizations

  I was originally only counting 1 per row which housed any X that became XMAS in any dir by overwriting acc rather than adding

  I got lucky where my p2 was pretty easy thanks to how I happened to do p1. I actually check less stuff.

  in p1 I originally write up, down, left, right, upright, etc. but collapsed to the transformations arr
  so I could live with myself
  """

  alias Helpers.CalbeGrid

  @mas "XMAS"

  def part1(input) do

    grid = CalbeGrid.parse(input, "\n", "")
    grid_len = CalbeGrid.get_grid_len(grid)
    grid_width = CalbeGrid.get_grid_width(grid)

    transformations = [
      fn ({x, y}, dist) -> {x, y - dist} end,
      fn ({x, y}, dist) -> {x, y + dist} end,
      fn ({x, y}, dist) -> {x - dist, y} end,
      fn ({x, y}, dist) -> {x + dist, y} end,
      fn ({x, y}, dist) -> {x + dist, y - dist} end,
      fn ({x, y}, dist) -> {x + dist, y + dist} end,
      fn ({x, y}, dist) -> {x - dist, y + dist} end,
      fn ({x, y}, dist) -> {x - dist, y - dist} end
    ]

    Enum.reduce(0..(grid_len - 1), 0, fn y, acc ->

      xmas_started_in_row = Enum.reduce(0..(grid_width - 1), 0, fn x, acc ->
        cell = CalbeGrid.get_by_x_y(grid, x, y)
        if cell == "X" do
          # we've found an X, so let's look in all dirs to see if we can find MAS

          xmas_started_from_point = Enum.map(transformations, fn transformation ->
            Enum.reduce(1..3, true, fn i, acc ->
              {tx, ty} = transformation.({x, y}, i)
              if CalbeGrid.get_by_x_y(grid, tx, ty) == String.slice(@mas, i, 1) do
                acc
              else
                false
              end
            end)
          end)
          |> Enum.map(fn dir ->
            if dir do
              1
            else
              0
            end
          end)
          |> Enum.sum()

          acc + xmas_started_from_point
        else
          acc
        end
      end)

      acc + xmas_started_in_row
    end)
  end

  defp get_crossmas_pairs(grid, x, y) do
    [
      {CalbeGrid.get_by_x_y(grid, x - 1, y - 1), CalbeGrid.get_by_x_y(grid, x + 1, y + 1)},
      {CalbeGrid.get_by_x_y(grid, x + 1, y - 1), CalbeGrid.get_by_x_y(grid, x - 1, y + 1)}
    ]
  end

  def part2(input) do
    grid = CalbeGrid.parse(input, "\n", "")

    grid_len = CalbeGrid.get_grid_len(grid)
    grid_width = CalbeGrid.get_grid_width(grid)

    Enum.reduce(0..(grid_len - 1), 0, fn y, acc ->

      crossmas_started_in_row = Enum.reduce(0..(grid_width - 1), 0, fn x, acc ->
        cell = CalbeGrid.get_by_x_y(grid, x, y)
        if cell == "A" do
          # found an A, determine if it's at the center of a crossmas

          pairs = get_crossmas_pairs(grid, x, y)

          if Enum.all?(pairs, fn {a, b} -> (a == "M" && b == "S") || (a == "S" && b == "M") end) do
            acc + 1
          else
            acc
          end
        else
          acc
        end
      end)

      acc + crossmas_started_in_row
    end)
  end
end
