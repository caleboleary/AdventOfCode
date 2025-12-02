defmodule AdventOfCode.Day02 do

  defp get_invalid_ids_in_range_same_digit_count(range_start, range_end) do

    start_digit_count = Integer.to_string(range_start) |> String.length()
    end_digit_count = Integer.to_string(range_end) |> String.length()

    left_half_start =
      range_start
      |> Integer.to_string()
      |> String.slice(0, div(start_digit_count, 2))
      |> String.to_integer()

    left_half_end =
      range_end
      |> Integer.to_string()
      |> String.slice(0, div(end_digit_count, 2))
      |> String.to_integer()

    Enum.reduce(left_half_start..left_half_end, [], fn left_half, acc ->
      full_id = Integer.to_string(left_half) <> Integer.to_string(left_half)
      |> String.to_integer()

      if full_id >= range_start and full_id <= range_end do
        acc ++ [full_id]
      else
        acc
      end
    end)

  end


  defp get_invalid_ids_in_range(range_start, range_end) do
    start_digit_count = Integer.to_string(range_start) |> String.length()
    end_digit_count = Integer.to_string(range_end) |> String.length()

    IO.inspect({start_digit_count, end_digit_count}, label: "Digit Counts")

    # we only care about even digit ids, all odds will never matter
    # at a glance all ranges are no more than 1 digit apart so we can ignore for now

    invalid = cond do
      rem(start_digit_count, 2) == 1 and rem(end_digit_count, 2) == 1 ->
        # both odd digit counts, no invalid ids possible
        []

      rem(start_digit_count, 2) == 0 and rem(end_digit_count, 2) == 0 && start_digit_count == end_digit_count ->
        # same digit count, both even, check full range
        get_invalid_ids_in_range_same_digit_count(range_start, range_end)

      rem(start_digit_count, 2) == 0 and rem(end_digit_count, 2) == 1 ->
        # start even, end odd, check from start to largest even with same digit count
        get_invalid_ids_in_range_same_digit_count(range_start, String.duplicate("9", start_digit_count) |> String.to_integer())

      rem(start_digit_count, 2) == 1 and rem(end_digit_count, 2) == 0 ->
        # start odd, end even, check from smallest even with same digit count to end
        get_invalid_ids_in_range_same_digit_count(trunc(:math.pow(10, end_digit_count - 1)), range_end)

      true ->
        throw "Unhandled case for range #{range_start}-#{range_end}"
    end

  end

  def part1(input) do
    ranges = input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(fn range ->
      [start_str, end_str] = String.split(range, "-", trim: true)
      {String.to_integer(start_str), String.to_integer(end_str)}
    end)

    IO.inspect(ranges, label: "Parsed Ranges")

    invalid_ids = ranges
    |> Enum.map(fn {range_start, range_end} ->
      get_invalid_ids_in_range(range_start, range_end)
    end)
    |> IO.inspect(label: "Invalid IDs per Range", charlists: :as_lists)
    |> List.flatten()
    |> IO.inspect(label: "All Invalid IDs", charlists: :as_lists)
    |> Enum.reduce(0, fn id, acc -> acc + id end)

  end

  defp get_p2_invalid_ids_in_range_same_digit_count(range_start, range_end) do
    start_digit_count = Integer.to_string(range_start) |> String.length()
    end_digit_count = Integer.to_string(range_end) |> String.length()

    IO.inspect({range_start, range_end}, label: "P2 Range - Same Digit Count invoked")

    end_target_denom =  start_digit_count
    |> IO.inspect(label: "End Target Denominator for range #{range_start}-#{range_end}")
    Enum.map(2..end_target_denom, fn denominator ->
      if rem(start_digit_count, denominator) == 0 do
        segment_length = div(start_digit_count, denominator)

        segment_start =
          range_start
          |> Integer.to_string()
          |> String.slice(0, segment_length)
          |> String.to_integer()
          |> IO.inspect(label: "Segment Start for denominator #{denominator}")

        segment_end =
          range_end
          |> Integer.to_string()
          |> String.slice(0, segment_length)
          |> String.to_integer()
          |> IO.inspect(label: "Segment End for denominator #{denominator}")

        Enum.reduce(segment_start..segment_end, [], fn segment, acc ->
          full_id =
            Integer.to_string(segment)
            |> String.duplicate(denominator)
            |> String.to_integer()

          if full_id >= range_start and full_id <= range_end do
            IO.inspect(full_id, label: "Found P2 invalid ID for denominator #{denominator}")
            IO.inspect({range_start, range_end}, label: "Range")
            IO.inspect(segment, label: "Segment")
            acc ++ [full_id]
          else
            acc
          end
        end)


      else
        []
      end
    end)
  end

  defp get_p2_invalid_ids_in_range(range_start, range_end) do
    # for a given range, say 1000-20000, we want to test making repeating
    # sequences first with 1/2, then 1/3, then 1/4, all the way to 1/(len/2)

    # for example 2121212118-2121212124 (10 digits)
    # first test 1/2 21212 + 21212 which exceeds end
    # then test 1/3 - fails as 10 not divisible by 3
    # then test 1/4 - 212 + 212 + 212 + 212 which exceeds end
    # then test 1/5 - 21 + 21 etc - succeeds

    # now odds and evens are all fair game, but we test them separately

    start_digit_count = Integer.to_string(range_start) |> String.length()
    end_digit_count = Integer.to_string(range_end) |> String.length()

    cond do
      start_digit_count == end_digit_count ->
        # same digit count, both even, check full range
        get_p2_invalid_ids_in_range_same_digit_count(range_start, range_end)


      start_digit_count < end_digit_count ->
        bottom_start = range_start
        |> IO.inspect(label: "Bottom Start for range #{range_start}-#{range_end}")

        bottom_end = String.duplicate("9", end_digit_count - 1) |> String.to_integer()
        |> IO.inspect(label: "Bottom End for range #{range_start}-#{range_end}")

        top_start = trunc(:math.pow(10, end_digit_count - 1))
        |> IO.inspect(label: "Top Start for range #{range_start}-#{range_end}")
        top_end = range_end
        |> IO.inspect(label: "Top End for range #{range_start}-#{range_end}")

        get_p2_invalid_ids_in_range_same_digit_count(bottom_start, bottom_end) ++
        get_p2_invalid_ids_in_range_same_digit_count(top_start, top_end)

      true ->
        throw "Unhandled case for range #{range_start}-#{range_end}"

    end
    |> List.flatten()

  end

  def part2(input) do
    ranges = input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(fn range ->
      [start_str, end_str] = String.split(range, "-", trim: true)
      {String.to_integer(start_str), String.to_integer(end_str)}
    end)

    IO.inspect(ranges, label: "Parsed Ranges")

    invalid_ids = ranges
    |> Enum.map(fn {range_start, range_end} ->
      get_p2_invalid_ids_in_range(range_start, range_end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn id -> id > 9 end)
    |> IO.inspect(label: "All P2 Invalid IDs", charlists: :as_lists)
    |> Enum.reduce(0, fn id, acc -> acc + id end)


  end
end
