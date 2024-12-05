defmodule AdventOfCode.Day05 do
  @moduledoc """
  This one was fun and a good challenge, I had to do a fair bit of docs reading
  to find the lang features I wanted.

  Had a little trouble getting the parsing just right

  Glad that using the custom sorting worked out, was a bit worried about what to
  do if there wasn't a rule for a pair but it appears that there always is.

  Sort of suspected that p2 might involve actually sorting by the rules
  """

  defp get_parsed_input(input) do
    [rules, updates] = String.split(input, "\n\n")
    |> Enum.map(&String.split(&1, "\n", trim: true))

    [
      rules |> Enum.map(fn x -> String.split(x, "|", trim: true) end),
      updates |> Enum.map(fn x -> String.split(x, ",", trim: true) end)
    ]
  end

  defp convert_update_to_map(update) do
    Enum.reduce(update, %{}, fn x, acc ->
      index = Enum.find_index(update, fn y -> y == x end)

      Map.put(acc, x, index)
    end)
  end

  defp convert_updates_to_map(updates) do
    Enum.map(updates, fn x -> convert_update_to_map(x) end)
  end

  defp get_is_rule_respected(rule, update_map) do
    [this_is, before_this] = rule
    Map.get(update_map, this_is) < Map.get(update_map, before_this, 10000000)
  end

  defp get_is_update_valid({update_map, _update}, rules) do
    relevant_rules = Enum.filter(rules, fn [rule, _] -> Map.has_key?(update_map, rule) end)

    Enum.all?(relevant_rules, fn rule ->
      get_is_rule_respected(rule, update_map)
    end)
  end

  def part1(input) do

    [rules, updates] = get_parsed_input(input)

    updates_and_map = convert_updates_to_map(updates)
    |> Enum.zip(updates)

    Enum.filter(updates_and_map, fn update_and_map ->
      get_is_update_valid(update_and_map, rules)
    end)
    |> Enum.map(fn {_update_map, update} ->
      middle_index = floor(length(update) / 2)

      update |> Enum.at(middle_index)
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp sort_update_by_rules({update_map, update}, rules) do
    relevant_rules = Enum.filter(rules, fn [a, b] -> Map.has_key?(update_map, a) || Map.has_key?(update_map, b) end)

    Enum.sort(update, fn a, b ->
      cond do
        Enum.any?(relevant_rules, fn [x, y] -> x == a && y == b end) -> true
        Enum.any?(relevant_rules, fn [x, y] -> x == b && y == a end) -> false
        true -> true
      end
    end)
  end

  def part2(input) do

    [rules, updates] = get_parsed_input(input)

    updates_and_map = convert_updates_to_map(updates)
    |> Enum.zip(updates)

    Enum.filter(updates_and_map, fn update_and_map ->
      !get_is_update_valid(update_and_map, rules)
    end)
    |>Enum.map(fn update_and_map -> sort_update_by_rules(update_and_map, rules) end)
    |> Enum.map(fn update ->
      middle_index = floor(length(update) / 2)

      update |> Enum.at(middle_index)
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end
