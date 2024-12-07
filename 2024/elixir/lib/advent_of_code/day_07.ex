defmodule AdventOfCode.Day07 do
  @moduledoc """
  This one was fun, I barked up the wrong tree for a bit, because I was trying to craft strings
  and then use Code.eval_string to evaluate them, but that doesn't respect the challenge's
  lack of order of operations, so I had to scrap a bunch of that work and pivot into
  evaluating them on my own, which wasn't too hard but probably cost me like 10-15 mintues.

  My p2 is also a little slow, maybe 20 sec or something, I do the full math for all possible
  permutations of operations but could pretty trivially break out the instant any single success
  is found.

  We could also stop doing math once our number gets too big for any given op permutation
  since all three operations grow the number. I may see how much that improves my p2 but not tonight.

  It felt great that part 2 only took me 2 minutes though, since I had built it in a way that allowed
  more operations to be added. TBH I expected subtract and divide to be added but was wrong.
  """

  defp get_parsed_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [total_str, operators_str] = String.split(line, ": ", trim: true)

      total = String.to_integer(total_str)

      operators = operators_str
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

      {total, operators}
    end)
  end

  defp apply_operations_to_operators(operators, operations) do
    Enum.reduce(1..Enum.count(operators), Enum.at(operators, 0), fn i, acc ->
      operator = Enum.at(operators, i)
      operation = Enum.at(operations, i - 1)

      case operation do
        "+" -> acc + operator
        "*" -> acc * operator
        "||" -> String.to_integer("#{acc}#{operator}")
        _ -> acc
      end
    end)
  end

  defp get_is_total_possible(total, operators, operations) do

    operation_permutations = generate_permutations_of_length(operations, Enum.count(operators) - 1)

    totals = Enum.map(operation_permutations, fn operation_permutation ->
      apply_operations_to_operators(operators, operation_permutation)
    end)

    Enum.any?(totals, fn t -> t == total end)
  end

  defp generate_permutations_of_length(operations, length) do
    generate_patterns(Enum.map(operations, fn operation -> [operation] end), length, operations)
  end

  defp generate_patterns(patterns, length, operations) do
    if List.first(patterns) |> length() == length do
      patterns
    else
      new_patterns = Enum.flat_map(operations, fn operation ->
        Enum.map(patterns, fn pattern ->
          pattern ++ [operation]
        end)
      end)

      generate_patterns(new_patterns, length, operations)
    end
  end

  def part1(input) do

    parsed = get_parsed_input(input)

    possible = Enum.filter(parsed, fn {total, operators} ->

      get_is_total_possible(total, operators, ["+", "*"])

    end)

    Enum.map(possible, fn {total, _} -> total end)
    |> Enum.sum()
  end

  def part2(input) do
    parsed = get_parsed_input(input)

    possible = Enum.filter(parsed, fn {total, operators} ->

      get_is_total_possible(total, operators, ["+", "*", "||"])

    end)

    Enum.map(possible, fn {total, _} -> total end)
    |> Enum.sum()
  end
end
