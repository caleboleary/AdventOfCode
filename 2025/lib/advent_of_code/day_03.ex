defmodule AdventOfCode.Day03 do

  defp get_leftmost_highest_num(bank) do
    highest_num = Enum.max(bank)
    position = Enum.find_index(bank, fn x -> x == highest_num end)

    {highest_num, position}
  end

  def part1(input) do
    banks = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)

    max_joltages = banks
    |> Enum.map(fn bank ->

      bank_without_last = Enum.slice(bank, 0, length(bank) - 1)

      {highest_num, position} = get_leftmost_highest_num(bank_without_last)

      # get sublist to the right of position
      right_sublist = Enum.slice(bank, position + 1, length(bank) - position - 1)

      {second_highest_num, _} = get_leftmost_highest_num(right_sublist)

      # IO.inspect({highest_num, second_highest_num}, label: "highest and second highest")

      "#{highest_num}#{second_highest_num}" |> String.to_integer()

    end)

    Enum.sum(max_joltages)
  end

  def part2(input) do

    banks = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)

    max_joltages = banks
    |> Enum.map(fn bank ->

      bank_without_last_12 = Enum.slice(bank, 0, length(bank) - 11)

      Enum.reduce(0..11, {bank_without_last_12, []}, fn i, acc ->

        {bank_acc, joltage_acc} = acc
        # |> IO.inspect(label: "acc at iteration #{i}", charlists: :as_lists)

        {highest_num, position} = get_leftmost_highest_num(bank_acc)
        # |> IO.inspect(label: "highest num and position at iteration #{i}")

        right_sublist = Enum.slice(bank_acc, position + 1, length(bank_acc))

        # add back on the next from the original bank based on i
        # so when i = 0, we add back on the 12th from the end, etc
        # once i == 11 we need to have added back all 12

        new_bank = right_sublist ++ [Enum.at(bank, length(bank) - 12 + i + 1)]
        # |> IO.inspect(label: "new bank at iteration #{i}")

        new_joltage_acc = joltage_acc ++ [highest_num]

        {new_bank, new_joltage_acc}

      end)
      # |> IO.inspect(label: "final acc")
      |> elem(1)
      |> Enum.join()
      |> String.to_integer()
      # |> IO.inspect(label: "final joltage for bank")

    end)

    Enum.sum(max_joltages)

  end
end
