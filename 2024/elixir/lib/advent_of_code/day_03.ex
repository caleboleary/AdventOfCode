defmodule AdventOfCode.Day03 do
  def part1(input) do
    Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, input)
    # |> IO.inspect()
    |> Enum.map(fn mul ->
      nums =
        Enum.at(mul, 0)
        |> String.replace("mul(", "")
        |> String.replace(")", "")
        |> String.split(",")
        # |> IO.inspect()
        |> Enum.map(&String.to_integer/1)

      Enum.at(nums, 0) * Enum.at(nums, 1)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)|do\(\)|don\'t\(\)/, input)
    |> Enum.reduce(%{to_sum: [], is_active: true}, fn instruction, acc ->
      case instruction do
        ["do()"] ->
          %{acc | is_active: true}

        ["don't()"] ->
          %{acc | is_active: false}

        [mul] ->
          if acc.is_active do
            nums =
              mul
              |> String.replace("mul(", "")
              |> String.replace(")", "")
              |> String.split(",")
              |> Enum.map(&String.to_integer/1)

            %{acc | to_sum: [Enum.at(nums, 0) * Enum.at(nums, 1) | acc.to_sum]}
          else
            acc
          end
      end
    end)
    |> IO.inspect()
    |> Map.get(:to_sum)
    |> Enum.sum()
  end
end
