defmodule AdventOfCode.Day07 do
  alias Helpers.CalbeGrid

  defp simulate_beam(grid, split_count, beam_row) do
    width = CalbeGrid.get_grid_width(grid)
    len = CalbeGrid.get_grid_len(grid)

    if beam_row >= len - 1 do
      {grid, split_count}
    else

      {grid_with_one_more_layer, splits_this_turn} = Enum.reduce(0..(width - 1), {grid, 0}, fn x, {acc, splits} ->
        cell = CalbeGrid.get_by_x_y(acc, x, beam_row)

        if cell == "|" do
          below_cell = CalbeGrid.get_by_x_y(acc, x, beam_row + 1)

          cond do
            below_cell == "." ->
              {CalbeGrid.set_by_x_y(acc, x, beam_row + 1, "|"), splits}
            below_cell == "^" ->
              new_grid = CalbeGrid.set_by_x_y(acc, x - 1, beam_row + 1, "|")
              |> CalbeGrid.set_by_x_y(x + 1, beam_row + 1, "|")

              {new_grid, splits + 1}
            below_cell == "|" ->
              # someone else got to it
              {acc, splits}
            true ->
              throw "AHHHHH #{inspect below_cell}"
          end
        else
          {acc, splits}
        end

      end)

      IO.inspect(splits_this_turn, label: "Splits this turn at row #{beam_row}")
      simulate_beam(grid_with_one_more_layer, split_count + splits_this_turn, beam_row + 1)
    end
  end

  def part1(input) do
    grid = CalbeGrid.parse(input, "\n", "")
    |> CalbeGrid.visualize_grid()

    start_pos = CalbeGrid.find_point(grid, fn cell -> cell == "S" end)

    beam_pos = {elem(start_pos, 0), elem(start_pos, 1) + 1}

    grid_with_init_beam = CalbeGrid.set_by_x_y(grid, elem(beam_pos, 0), elem(beam_pos, 1), "|")

    {final_grid, split_count} = simulate_beam(grid_with_init_beam, 0, elem(beam_pos, 1))

    final_grid |> CalbeGrid.visualize_grid()
    IO.inspect(split_count, label: "Split Count")
  end

  defp simulate_beam_p2(grid, timeline_counts, beam_row) do
    width = CalbeGrid.get_grid_width(grid)
    len = CalbeGrid.get_grid_len(grid)

    if beam_row >= len - 1 do
      {grid, timeline_counts}
    else

      empty_tlc = List.duplicate(0, width)

      {grid_with_one_more_layer, timeline_counts_next_layer} = Enum.reduce(0..(width - 1), {grid, empty_tlc}, fn x, {acc, tlc} ->
        cell = CalbeGrid.get_by_x_y(acc, x, beam_row)
        timeline_count = Enum.at(timeline_counts, x)

        if cell == "|" do
          below_cell = CalbeGrid.get_by_x_y(acc, x, beam_row + 1)

          cond do
            below_cell == "." ->
              {CalbeGrid.set_by_x_y(acc, x, beam_row + 1, "|"), List.replace_at(tlc, x, timeline_count + Enum.at(tlc, x))}
            below_cell == "^" ->
              new_grid = CalbeGrid.set_by_x_y(acc, x - 1, beam_row + 1, "|")
              |> CalbeGrid.set_by_x_y(x + 1, beam_row + 1, "|")

              new_tlc = tlc
              |> List.replace_at(x - 1, timeline_count + Enum.at(tlc, x - 1))
              |> List.replace_at(x + 1, timeline_count + Enum.at(tlc, x + 1))
              |> List.replace_at(x, 0)

              {new_grid, new_tlc}
            below_cell == "|" ->
              # someone else got to it
              {acc, List.replace_at(tlc, x, timeline_count + Enum.at(tlc, x))}
            true ->
              throw "AHHHHH #{inspect below_cell}"
          end
        else
          {acc, List.replace_at(tlc, x, timeline_count + Enum.at(tlc, x))}
        end
      end)

      simulate_beam_p2(grid_with_one_more_layer, timeline_counts_next_layer, beam_row + 1)
    end
  end

  def part2(input) do
    grid = CalbeGrid.parse(input, "\n", "")
    |> CalbeGrid.visualize_grid()

    start_pos = CalbeGrid.find_point(grid, fn cell -> cell == "S" end)

    beam_pos = {elem(start_pos, 0), elem(start_pos, 1) + 1}

    grid_with_init_beam = CalbeGrid.set_by_x_y(grid, elem(beam_pos, 0), elem(beam_pos, 1), "|")

    empty_timeline_counts = List.duplicate(0, CalbeGrid.get_grid_width(grid))
    |> List.replace_at(elem(beam_pos, 0), 1)

    {final_grid, timeline_counts} = simulate_beam_p2(grid_with_init_beam, empty_timeline_counts, elem(beam_pos, 1))

    final_grid |> CalbeGrid.visualize_grid()
    IO.inspect(timeline_counts, label: "timeline Count")

    timeline_counts |> Enum.sum()

  end
end
