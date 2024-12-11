defmodule AdventOfCode.Day11 do
  @moduledoc """
    I knew the instant that it seemed too simple on p1 that p2 was going to ask for more steps
    though I figured it'd be like a billion or something not 75. My code could run to around 43
    naively before it began to crawl.

    Did a little looking at the arrays as they grew and considered trying to memoize what became
    what over time but I couldn't even run [0] for 75 turns haha,

    Thankfully had the idea to try Enum.uniq and it drastically reduced the arr size
    so I ran with that and it made things possible. My pt2 runs in about 2 seconds.

    My p2 variant would work fine on p2 but I want to leave the old one to preserve
    the evolution.
  """

  defp get_parsed_input(input) do
    input
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)

  end

  defp process_blink(stones) do
    Enum.map(stones, fn stone ->

      str_len = String.length("#{stone}")

      cond do
        stone == 0 -> 1
        str_len |> rem(2) == 0 -> [
          String.to_integer(String.slice("#{stone}", 0, floor(str_len / 2))),
          String.to_integer(String.slice("#{stone}", floor(str_len / 2), floor(str_len / 2)))
        ]
        true -> stone * 2024
      end
    end)
    |> List.flatten()
  end

  def part1(input) do
    parsed = get_parsed_input(input)
    |> IO.inspect(label: "parsed")

    Enum.reduce(1..25, parsed, fn _index, acc ->
      process_blink(acc)
    end)
    |> Enum.count()
  end

  defp process_blink_p2(stones) do
    Enum.map(stones, fn {stone_value, stone_count} ->

      str_len = String.length("#{stone_value}")

      cond do
        stone_value == 0 -> {1, stone_count}
        str_len |> rem(2) == 0 -> [
          {String.to_integer(String.slice("#{stone_value}", 0, floor(str_len / 2))), stone_count},
          {String.to_integer(String.slice("#{stone_value}", floor(str_len / 2), floor(str_len / 2))), stone_count}
        ]
        true -> {stone_value * 2024, stone_count}
      end

    end)
    |> List.flatten()
    |> Enum.reduce([], fn {stone_value, stone_count}, acc ->
      if Enum.any?(acc, fn {acc_val, _acc_count} -> acc_val == stone_value end) do
        existing_index = Enum.find_index(acc, fn {acc_val, _acc_count} -> acc_val == stone_value end)
        existing = Enum.at(acc, existing_index)
        [{stone_value, stone_count + elem(existing, 1)} | List.delete_at(acc, existing_index)]
      else
        [{stone_value, stone_count} | acc]
      end
    end)
  end

  def part2(input) do

    parsed = get_parsed_input(input)
    |> IO.inspect(label: "parsed")
    |> Enum.map(fn x -> {x, 1} end)
    # {number, count}
    |> IO.inspect(label: "parsed2")

    Enum.reduce(1..75, parsed, fn index, acc ->
      IO.inspect(index, label: "index")
      process_blink_p2(acc)
    end)
    |> Enum.reduce(0, fn {stone_value, stone_count}, acc -> acc + stone_count end)
  end
end
