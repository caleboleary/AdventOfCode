defmodule AdventOfCode.Day02 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn list ->
      Enum.map(list, &String.to_integer/1)
    end)
  end

  defp test_report(report) do
    is_unique = Enum.uniq(report) == report

    is_sorted = Enum.sort(report) == report

    is_inverse_sorted = Enum.sort(report) == Enum.reverse(report)

    largest_step = Enum.with_index(report) |> Enum.reduce(1, fn {current, idx}, acc ->
      prev = Enum.at(report, idx - 1)

      diff = abs(current - prev)

      if diff > acc && idx > 0 do
        diff
      else
        acc
      end
    end)

    if (is_unique && is_sorted) || (is_unique && is_inverse_sorted) do
      if largest_step < 4 do
        1
      else
        0
      end
    else
      0
    end
  end

  def part1(input) do

    parse_input(input)
    |> Enum.map(fn report ->
      test_report(report)
    end)
    |> Enum.sum()
  end

  defp test_report_sans_any_entry(report) do
    fixable = report
    |> Enum.with_index()
    |> Enum.map(fn {_entry, idx} ->
      List.delete_at(report, idx)
      |> test_report
    end)
    |> Enum.any?(fn result -> result == 1 end)

    if fixable do
      1
    else
      0
    end
  end

  def part2(input) do
    parsed = parse_input(input)

    Enum.map(parsed, fn report ->
      test_report(report)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {result, idx} ->
      if result == 0 do
        test_report_sans_any_entry(Enum.at(parsed, idx))
      else
        1
      end
    end)
    |> Enum.sum()
  end
end
