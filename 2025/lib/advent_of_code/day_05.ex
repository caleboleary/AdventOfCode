defmodule AdventOfCode.Day05 do
  def part1(input) do
    [raneges_str, ingreds_str] = String.split(input, "\n\n", trim: true)

    ranges = raneges_str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [start_str, end_str] = String.split(line, "-", trim: true)
      {String.to_integer(start_str), String.to_integer(end_str)}
    end)

    ingreds = ingreds_str
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)

    Enum.filter(ingreds, fn ingred ->
      Enum.find(ranges, fn {range_start, range_end} ->
        ingred >= range_start and ingred <= range_end
      end) != nil
    end)
    |> length()

  end

  defp merge_ranges(ranges) do
    # find an overlapping pair
    # if none, return ranges
    # else, merge them and call again

    candidate_index = Enum.reduce_while(1..(length(ranges) - 1), nil, fn index, _acc ->
      {prev_start, prev_end} = Enum.at(ranges, index - 1)
      {curr_start, curr_end} = Enum.at(ranges, index)

      if prev_end >= curr_start do
        {:halt, index}
      else
        {:cont, nil}
      end
    end)

      if candidate_index == nil do
        ranges
      else
        {prev_start, prev_end} = Enum.at(ranges, candidate_index - 1)
        {curr_start, curr_end} = Enum.at(ranges, candidate_index)

        merged_range = {prev_start, max(prev_end, curr_end)}

        List.replace_at(ranges, candidate_index - 1, merged_range)
        |> List.delete_at(candidate_index)
        |> merge_ranges()
      end
  end

  def part2(input) do
    [raneges_str, _ingreds_str] = String.split(input, "\n\n", trim: true)

    ranges = raneges_str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [start_str, end_str] = String.split(line, "-", trim: true)
      {String.to_integer(start_str), String.to_integer(end_str)}
    end)

    sorted_ranges = ranges
    |> Enum.sort_by(fn {start, _end} -> start end)
    |> IO.inspect(label: "Sorted Ranges")

    merged_ranges = merge_ranges(sorted_ranges)
    |> IO.inspect(label: "Merged Ranges")

    Enum.reduce(merged_ranges, 0, fn {range_start, range_end}, acc ->
      acc = acc + (range_end - range_start) + 1
    end)


  end
end
