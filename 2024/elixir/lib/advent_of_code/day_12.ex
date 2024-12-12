defmodule AdventOfCode.Day12 do
  @moduledoc """
  This one was pretty tough for me. Part one came quickly but part two was difficult and felt mathy
  I ended up doing it a programmer way rather than a mathy way haha, probably some formula out there
  or something that could have answered it in less work, but I had some fun trying to conceptualize
  how the barrier between one of our in points and an out point made up a side. For instance we
  have to call a single point region as having 4 sides, so you can think of those 4 sides as
  four barriers between the point and its 4 non region neighbors. Fun to figure out, but ready for bed
  """

  alias Helpers.CalbeGrid

  defp get_parsed_input(input) do
    input
    |> CalbeGrid.parse("\n", "")
    |> CalbeGrid.visualize_grid()

  end

  defp get_region_neighbors(grid, {x, y}, known_region) do
    type = CalbeGrid.get_by_x_y(grid, x, y)
    bfs(grid, [{x, y}], known_region, type)
  end

  defp bfs(grid, [], known_region, _type), do: known_region
  defp bfs(grid, [current | rest], known_region, type) do
      {x, y} = current

      neighbors = [
          {x, y - 1},
          {x, y + 1},
          {x - 1, y},
          {x + 1, y}
      ]
      |> Enum.filter(fn {x, y} -> CalbeGrid.get_is_point_in_bounds(grid, {x, y}) end)
      |> Enum.filter(fn {x, y} -> !Enum.member?(known_region, {x, y}) end)
      |> Enum.filter(fn {x, y} -> CalbeGrid.get_by_x_y(grid, x, y) == type end)

      if neighbors == [] do
          bfs(grid, rest, known_region, type)
      else
          bfs(grid, rest ++ neighbors, known_region ++ neighbors, type)
      end
  end

  defp find_region_from_point(grid, {x, y}) do
    get_region_neighbors(grid, {x, y}, [{x, y}])
  end

  defp get_region_perimeter(grid, region) do
    Enum.reduce(region, 0, fn {x, y}, acc ->
      acc + Enum.count([
        {x, y - 1},
        {x, y + 1},
        {x - 1, y},
        {x + 1, y}
      ], fn {x, y} -> !Enum.member?(region, {x, y}) end)
    end)
  end

  def part1(input) do
    parsed = get_parsed_input(input)

    regions = Enum.reduce(0..(CalbeGrid.get_grid_len(parsed) - 1), [], fn y, acc ->
      Enum.reduce(0..(CalbeGrid.get_grid_width(parsed) - 1), acc, fn x, acc ->
        if Enum.any?(acc, fn region -> Enum.member?(region, {x, y}) end) do
          acc
        else
          Enum.concat(acc, [find_region_from_point(parsed, {x, y})])
        end
      end)
    end)

    Enum.reduce(regions, 0, fn region, acc ->
      acc + (get_region_perimeter(parsed, region) * Enum.count(region))
    end)

  end


  defp get_region_sides(grid, region) do
    perimeter = Enum.filter(region, fn {x, y} ->
      Enum.any?([
        {x, y - 1},
        {x, y + 1},
        {x - 1, y},
        {x + 1, y}
      ], fn {x, y} -> !Enum.member?(region, {x, y}) end)
    end)

    Enum.reduce(perimeter, [], fn {x, y}, acc_sides ->
      non_region_neighbors = [
        {x, y - 1},
        {x, y + 1},
        {x - 1, y},
        {x + 1, y}
      ]
      |> Enum.filter(fn {x, y} -> !Enum.member?(region, {x, y}) end)
      |> Enum.filter(fn {nx, ny} ->
        !Enum.any?(acc_sides, fn side ->
          Enum.member?(side, {{x, y}, {nx, ny}})
        end)
      end)

      # each of these non region neighbors is a side, lets traverse them to get the full list of points
      # which make up said side. it's not really the points, but the barrier between said point and outside the region
      # trying to think of if we need to store the point and the point opposite the barrier.

      previously_unfound_sides = Enum.map(non_region_neighbors, fn {nrnx, nrny} ->
        vector = {nrny - y, nrnx - x} # purposefully reversed
        nevative_vector = {-1 * elem(vector, 0), -1 * elem(vector, 1)}

        transform = {nrnx - x, nrny - y}

        limit = 1000

        pos = Enum.reduce_while(1..limit, [{{x, y}, {nrnx, nrny}}], fn _iteration, acc ->
          [{current, opposite} | rest] = acc

          next = {elem(current, 0) + elem(vector, 0), elem(current, 1) + elem(vector, 1)}
          next_opposite = {elem(next, 0) + elem(transform, 0), elem(next, 1) + elem(transform, 1)}

          if Enum.member?(region, next) && !Enum.member?(region, next_opposite) do
            {:cont, [{next, next_opposite} | acc]}
          else
            {:halt, acc}
          end
        end)

        neg = Enum.reduce_while(1..limit, [{{x, y}, {nrnx, nrny}}], fn _iteration, acc ->
          [{current, opposite} | rest] = acc

          next = {elem(current, 0) + elem(nevative_vector, 0), elem(current, 1) + elem(nevative_vector, 1)}
          next_opposite = {elem(next, 0) + elem(transform, 0), elem(next, 1) + elem(transform, 1)}

          if Enum.member?(region, next) && !Enum.member?(region, next_opposite) do
            {:cont, [{next, next_opposite} | acc]}
          else
            {:halt, acc}
          end
        end)

        # this list is all points on this side.
        (pos ++ neg) |> Enum.uniq()

      end)

      acc_sides ++ previously_unfound_sides

    end)
    |> Enum.count()

  end

  def part2(input) do
    parsed = get_parsed_input(input)

    regions = Enum.reduce(0..(CalbeGrid.get_grid_len(parsed) - 1), [], fn y, acc ->
      Enum.reduce(0..(CalbeGrid.get_grid_width(parsed) - 1), acc, fn x, acc ->
        if Enum.any?(acc, fn region -> Enum.member?(region, {x, y}) end) do
          acc
        else
          Enum.concat(acc, [find_region_from_point(parsed, {x, y})])
        end
      end)
    end)

    Enum.map(regions, fn region ->
      get_region_sides(parsed, region) * Enum.count(region)
    end)
    |> Enum.sum()
  end
end
