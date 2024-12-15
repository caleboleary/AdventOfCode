defmodule AdventOfCode.Day14 do

  @moduledoc """
  This part 1 was pretty easy though I had some annoying bugs at first

  This part 2 was wild with the absolute lack of information, but that sort of
  turn it into a fun puzzle rather than a programming challenge.

  Leaving in all my random flailing around commented out.
  What finally did it for me was noticing that at 9995 there was
  a big cluster near the verticla center, just noticed as I watched some scroll by

  I started searching for times when there were clusters in the vertical center
  and tried to slow the cascade down enough and eventually spotted it fly by and
  cancelled my program fast enough that it didn't flow out of my terminal.

  Some other stuff I tried that didn't work (and why):
  - checking for when the entire bottom row was filled (isn't formed like this)
  - looking for perfect symmetry left to right (not centered)
  - looking for mostly symmetry left to right (not centered)

  """

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, vx, vy] = Regex.scan(~r/(-?\d+)/, line)
      |> Enum.map(fn x -> List.first(x) end)
      |> Enum.map(&String.to_integer/1)

      {{x, y}, {vx, vy}}
    end)
  end

  defp get_position_after_turns({x, y}, {vx, vy}, turns, width, height) do
    x_unadj = x + (vx * turns)
    x_pos = rem(rem(x_unadj, width) + width, width)

    y_unadj = y + (vy * turns)
    y_pos = rem(rem(y_unadj, height) + height, height)

    {x_pos, y_pos}
  end

  defp count_bots_in_quadrants(positions, width, height) do
    Enum.reduce(positions, %{
      top_left: 0,
      top_right: 0,
      bottom_left: 0,
      bottom_right: 0
    }, fn {x, y}, acc ->
      cond do
        x < floor(width / 2) and y < floor(height / 2) -> Map.update!(acc, :top_left, &(&1 + 1))
        x >= ceil(width / 2) and y < floor(height / 2) -> Map.update!(acc, :top_right, &(&1 + 1))
        x < floor(width / 2) and y >= ceil(height / 2) -> Map.update!(acc, :bottom_left, &(&1 + 1))
        x >= ceil(width / 2) and y >= ceil(height / 2) -> Map.update!(acc, :bottom_right, &(&1 + 1))
        true -> acc
      end
    end)
  end

  def part1(input) do
    parsed = get_parsed_input(input)
    |> IO.inspect(label: "parsed")

    # {width, height} = if String.split(input, "\n", trim: true) |> List.first() == "p=2,4 v=2,-3" do
      {width, height} = if String.split(input, "\n", trim: true) |> List.first() == "p=0,4 v=3,-3" do

      {11, 7}
    else
      {101, 103}
    end

    Enum.map(parsed, fn {{x, y}, {vx, vy}} ->
      get_position_after_turns({x, y}, {vx, vy}, 100, width, height)
    end)
    |> IO.inspect(label: "positions")
    |> count_bots_in_quadrants(width, height)
    |> IO.inspect(label: "quadrants")
    |> Map.values()
    |> Enum.reduce(fn x, acc -> acc * x end)
    |> IO.inspect(label: "count_bots_in_quadrants")
  end

  def part2(input) do
    parsed = get_parsed_input(input)
    |> IO.inspect(label: "parsed")

    # {width, height} = if String.split(input, "\n", trim: true) |> List.first() == "p=2,4 v=2,-3" do
      {width, height} = if String.split(input, "\n", trim: true) |> List.first() == "p=0,4 v=3,-3" do

      {11, 7}
    else
      {101, 103}
    end

    empty_row = List.duplicate(".", width) |> Enum.join()
    empty_grid = List.duplicate(empty_row, height) |> Enum.join("\n")
    |> CalbeGrid.parse("\n", "")

    CalbeGrid.visualize_grid(empty_grid)



    limit = 1000000
    Enum.map(1..limit, fn i ->
      positions = Enum.map(parsed, fn {{x, y}, {vx, vy}} ->
        get_position_after_turns({x, y}, {vx, vy}, i, width, height)
      end)
      # |> Enum.uniq()

      if rem(i, 1000) == 0 do
        IO.inspect(i)
      end

      # quadrants = count_bots_in_quadrants(positions, width, height)

      # if (quadrants.top_left == quadrants.top_right && quadrants.bottom_left == quadrants.bottom_right && quadrants.top_left < quadrants.bottom_left) do
      #   IO.inspect(i)
      #   IO.inspect(quadrants)
      #   Enum.reduce(positions, empty_grid, fn {x, y}, acc ->
      #     CalbeGrid.set_by_x_y(acc, x, y, "#")
      #   end)
      #   |> CalbeGrid.visualize_grid()
      # end

      # if the entire bottom row is filled, log
      # if Enum.all?(0..(width - 1), fn x -> Enum.member?(positions, {x, height - 1}) end) do
      #   IO.inspect(i)
      #   Enum.reduce(positions, empty_grid, fn {x, y}, acc ->
      #     CalbeGrid.set_by_x_y(acc, x, y, "#")
      #   end)
      #   |> CalbeGrid.visualize_grid()
      # end

      # if the entire left half (sans center row) mirrored equalt the right half (sans center row), log
      # # for each point, check if the mirrored point is in the list
      # if Enum.all?(positions, fn {x, y} -> Enum.member?(positions, {width - x - 1, y}) end) do
      #   IO.inspect(i)
      #   Enum.reduce(positions, empty_grid, fn {x, y}, acc ->
      #     CalbeGrid.set_by_x_y(acc, x, y, "#")
      #   end)
      #   |> CalbeGrid.visualize_grid()
      # end

      # count number of points which do have a mirror
      # if above certain percentage, log
      # mirrored_points = Enum.map(positions, fn {x, y} -> {width - x - 1, y} end)
      # mirrored_points_count = Enum.count(positions, fn {x, y} -> Enum.member?(mirrored_points, {x, y}) end)
      # mirrored_points_percentage = mirrored_points_count / length(positions)

      # if mirrored_points_percentage > 0.5 do
      #   IO.inspect(i)
      #   Enum.reduce(positions, empty_grid, fn {x, y}, acc ->
      #     CalbeGrid.set_by_x_y(acc, x, y, "#")
      #   end)
      #   |> CalbeGrid.visualize_grid()
      # end

      # just log them all
      # IO.inspect(i)
      # Enum.reduce(positions, empty_grid, fn {x, y}, acc ->
      #   CalbeGrid.set_by_x_y(acc, x, y, "#")
      # end)
      # |> CalbeGrid.visualize_grid()


      # log when there is a high amount of points in the vertical central 40 lines
      if Enum.count(positions, fn {x, y} -> y >= 30 && y <= 70 && x > 30 && x < 70 end) > 300 do
        IO.inspect(i)
        Enum.reduce(positions, empty_grid, fn {x, y}, acc ->
          CalbeGrid.set_by_x_y(acc, x, y, "#")
        end)
        |> CalbeGrid.visualize_grid()

        # sleep for a moment
        Process.sleep(100)
      end

    end)

    0
  end
end
