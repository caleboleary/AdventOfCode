defmodule AdventOfCode.Day19 do

  alias Helpers.Permutations

  defp get_parsed_input(input) do
    [avail, designs] =input
    |> String.split("\n\n", trim: true)

    avail = String.split(avail, ", ", trim: true)

    designs = String.split(designs, "\n", trim: true)

    {avail, designs}
  end

  defp get_is_design_possible(design, avail) do
    # for each shuffled list, loop all, replacing
    # if at end we have an empty string, return true

      replaced = Enum.reduce(avail, design, fn avail, acc ->
        String.replace(acc, avail, ".")
      end)

      if String.replace(replaced, ".", "") == "" do
        true
      else
        false
      end
  end

  defp bfs(design, avail, list) do
    # for each avail, see if the current design starts with it
    # if so, replace it out and run bfs again
    # if not prune that branch from the list

  end

  defp search_is_design_possible(design, avail) do
    bfs(design, avail, [%{
      design: design,
      used: []
    }])
  end

  def part1(input) do
    {avail, designs} = get_parsed_input(input)
    |> IO.inspect()

    IO.inspect(length(avail))

    max_avail_len = Enum.max_by(avail, &String.length/1) |> String.length()

    sorted = Enum.sort_by(avail, &String.length/1)

    single_digits = sorted
    |> Enum.filter(fn a ->
      String.length(a) < 2
    end)
    |> IO.inspect(label: "single_digits")

    relevant_avail = Enum.reduce(1..max_avail_len, [single_digits], fn i, acc ->
      digits = Enum.filter(sorted, fn a ->
        String.length(a) == i
      end)
      |> Enum.filter(fn a ->
        !get_is_design_possible(a, List.flatten(acc))
      end)
      |> IO.inspect(label: "digits #{i}")

      [digits | acc]
    end)
    |> List.flatten()
    |> IO.inspect(label: "relevant_avail")

    Enum.filter(designs, fn design ->
      search_is_design_possible(design, relevant_avail)
    end)
    |> Enum.count()

    # strs = relevant_avail |> Enum.join("|")

    # reg ="^(#{strs})*$" |> Regex.compile!()
    # |> IO.inspect(label: "regex")

    # Enum.filter(designs, fn design ->
    #   Regex.match?(reg, design)
    # end)
    # |> Enum.count()



    # IO.inspect(length(relevant_avail), label: "relevant_avail")

    # possible =
    #   Enum.with_index(designs)
    #   |> Enum.filter(fn {design, index} ->
    #     IO.inspect("design #{index} of #{length(designs)}")
    #     get_is_design_possible(design, relevant_avail)
    # end)
    # |> Enum.count()

    # 180 too low
    # 302 too low but close-ish - someone else's answer hah
  end

  def part2(input) do

  end
end
