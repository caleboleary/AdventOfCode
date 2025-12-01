defmodule AdventOfCode.Day22 do

  defp mix(secret_num, other) do
    Bitwise.bxor(secret_num, other)
  end

  defp prune(secret_num) do
    # think this is a power of 2 so probably bit shift
    rem(secret_num, 16777216)
  end

  defp simulate_next_number(secret_num) do
    # this could be a bit shift too I think
    mult = secret_num * 64
    s1 = mix(secret_num, mult)
    |> prune()

    # bit shift
    div = floor(s1 / 32)
    s2 = mix(s1, div)
    |> prune()

    # bit shift
    mult2 = s2 * 2048
    mix(s2, mult2)
    |> prune()
  end

  def part1(input) do
    parsed = input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)

    Enum.reduce(1..2000, parsed, fn _, acc ->
      Enum.map(acc, &simulate_next_number/1)
    end)
    |> Enum.sum()

  end

  defp get_does_pattern_occur_in_series(pattern, change_series) do
    # find the first index where index in change series is pattern[3] and the prev 3 match too.
    # then return the price at that index in ones_place_series

    fnd = Enum.with_index(change_series)
    |> Enum.find(fn {change, idx} ->
      if idx < 3 do
        false
      else
        Enum.slice(change_series, idx - 3, 3) == Enum.slice(pattern, 0, 3) && change == Enum.at(pattern, 3)
      end
    end)

    if (fnd == nil || !fnd) do
      false
    else
      true
    end
  end

  defp get_price_at_first_occurence_of_pattern(pattern, ones_place_series, change_series) do
    # find the first index where index in change series is pattern[3] and the prev 3 match too.
    # then return the price at that index in ones_place_series

    fnd = Enum.with_index(change_series)
    |> Enum.find(fn {change, idx} ->
      if idx < 3 do
        false
      else
        Enum.slice(change_series, idx - 3, 3) == Enum.slice(pattern, 0, 3) && change == Enum.at(pattern, 3)
      end
    end)

    if (fnd == nil || !fnd) do
      0
    else
      Enum.at(ones_place_series, elem(fnd, 1))
    end

  end

  def part2(input) do

    parsed = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn i ->
      [String.to_integer(i)]
    end)
    |> IO.inspect(label: "parsed")

    nums = Enum.reduce(1..2000, parsed, fn _, acc ->
      Enum.map(acc, fn series ->
        [simulate_next_number(List.first(series)) | series]
      end)
    end)
    |> Enum.map(fn series ->
      Enum.reverse(series)
    end)
    |> IO.inspect(label: "changes")


    ones = Enum.map(nums, fn series ->
      # get the last num from each entry (1 in 20041)
      Enum.map(series, fn entry ->
        rem(entry, 10)
      end)
    end)
    |> IO.inspect(label: "last digit")

    changes = Enum.map(ones, fn series ->
      # for each series, calc the diff from previous entry
      Enum.with_index(series)
      |> Enum.map(fn {entry, idx} ->
        if idx == 0 do
          0
        else
          entry - Enum.at(series, idx - 1)
        end
      end)
    end)
    |> IO.inspect(label: "changes")

    brute_force = for a <- -9..9,
        b <- -9..9,
        c <- -9..9,
        d <- -9..9 do
      [a, b, c, d]
    end
    |> Enum.filter(fn pattern ->
      Enum.with_index(changes)
      |> Enum.any?(fn {series, outer_idx} ->
        get_does_pattern_occur_in_series(pattern, series)
      end)
    end)

    IO.inspect(length(brute_force))

    Enum.with_index(brute_force)
    |> Enum.map(fn {pattern, bfidx} ->
      if rem(bfidx, 10) == 0 do
        IO.inspect("percent done: #{bfidx / length(brute_force) * 100}")
      end
      Enum.with_index(changes)
      |> Enum.map(fn {series, outer_idx} ->
        ones_place_series = Enum.at(ones, outer_idx)

        {pattern, get_price_at_first_occurence_of_pattern(pattern, ones_place_series, series)}
      end)
    end)
    |> IO.inspect(label: "brute force")
    |> Enum.max_by(fn {_, price} -> price end)

    # # let's find the highest 100 series outputs for each series
    # # and then we can find the highest combination of those 400 across all series
    # # and hopefully that's good enough

    # # let's form this into an easier to work with data structure
    # # maybe something like {price, [series1, series2, series3, series4]}
    # # then we can sort by price desc, and take the first 100

    # Enum.with_index(changes)
    # |> Enum.map(fn {series, outer_idx} ->
    #   Enum.with_index(series)
    #   |> IO.inspect(label: "series #{outer_idx}")
    #   |> Enum.map(fn {change_series, idx} ->
    #     if idx < 3 do
    #       nil
    #     else
    #       {ones |> Enum.at(outer_idx) |> Enum.at(idx), Enum.slice(series, idx, 4)}
    #     end
    #   end)
    #   |> Enum.filter(&(&1 != nil))
    #   |> IO.inspect(label: "series #{outer_idx}")
    #   |> Enum.sort_by(fn {price, _} -> price end, &>=/2)
    #   |> Enum.take(100)
    #   |> Enum.map(fn {price, series} ->
    #     series
    #   end)
    # end)
    # |> List.flatten()
    # |> IO.inspect(label: "top 400")




  end

end
