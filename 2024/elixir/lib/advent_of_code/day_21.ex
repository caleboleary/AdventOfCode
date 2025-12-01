defmodule AdventOfCode.Day21 do

  alias Helpers.CalbeGrid
  alias Helpers.Permutations

  use Memoize

  defp get_parsed_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, "", trim: true)
    end)
  end

# +---+---+---+
# | 7 | 8 | 9 |
# +---+---+---+
# | 4 | 5 | 6 |
# +---+---+---+
# | 1 | 2 | 3 |
# +---+---+---+
#     | 0 | A |
#     +---+---+

  @numpad "789
456
123
.0A"

#     +---+---+
#     | ^ | A |
# +---+---+---+
# | < | v | > |
# +---+---+---+

@arrowpad ".^A
<v>"

  defmemo get_bot_action(state, desired, type) do

    pad = case type do
      :numpad -> @numpad
      :arrowpad -> @arrowpad
    end

    # if perf issue move this out run once
    grid = CalbeGrid.parse(pad, "\n", "")

    state_coords = CalbeGrid.find_point(grid, fn c -> c == state end)
    desired_coords = CalbeGrid.find_point(grid, fn c -> c == desired end)

    x_diff = elem(desired_coords, 0) - elem(state_coords, 0)
    y_diff = elem(desired_coords, 1) - elem(state_coords, 1)

    # need to make some change here to ensure we don't walk over the .
    # if that's even really a problem
    x_change = if x_diff > 0 do
      List.duplicate(">", x_diff) |> Enum.join()
    else
      List.duplicate("<", abs(x_diff)) |> Enum.join()
    end

    y_change = if y_diff > 0 do
      List.duplicate("v", y_diff) |> Enum.join()
    else
      List.duplicate("^", abs(y_diff)) |> Enum.join()
    end

    # {x_change, y_change}

    # figure which x or y won't touch the .
    dot_coords = CalbeGrid.find_point(grid, fn c -> c == "." end)
    dot_x_diff = elem(dot_coords, 0) - elem(state_coords, 0)
    dot_y_diff = elem(dot_coords, 1) - elem(state_coords, 1)

    # if dot is 0 diff for either, we're currently in the same row or column as it
    # in this instance, we need to move other dir first so we don't touch it
    # if dot_x_diff != 0 && dot_y_diff != 0 do
      # [x_change <> y_change, y_change <> x_change]
    # else
      # if dot_x_diff == 0 do
        # [y_change <> x_change]
      # else
        # [x_change <> y_change]
      # end

    # end

    String.split(x_change <> y_change, "", trim: true)
    |> Permutations.of()
    # we need to filter out any that touch the dot
    # I think we can do this by snipping the first dot_x_diff + dot_y_diff off and seeing if that amount are in.
    |> Enum.filter(fn x_y_change ->
      first_n = Enum.take(x_y_change, abs(dot_x_diff) + abs(dot_y_diff))

      # if we go <<^^
      # if the first two contain << then we might touch dot etc.

    end)
    |> Enum.map(fn x_y_change ->
      Enum.join(x_y_change)
    end)
  end

  def part1(input) do
    parsed = get_parsed_input(input)
    |> IO.inspect(label: "parsed")

    to_enter = Enum.map(parsed, fn line ->
      bot2_bot1_encoded = Enum.reduce(line, {"A", [""]}, fn desired, {state, move_arrangements} ->
        valid_moves = get_bot_action(state, desired, :numpad)

        new_move_arrangements = Enum.map(move_arrangements, fn move ->
          Enum.map(valid_moves, fn valid_move -> move <> valid_move <> "A" end)
        end)
        |> List.flatten()

        {desired, new_move_arrangements}
      end)
      |> elem(1)

      sorted_by_len = Enum.uniq(bot2_bot1_encoded)
      |> Enum.sort_by(&String.length/1)
      |> IO.inspect(label: "sorted_by_len")
      lowest_len = Enum.at(sorted_by_len, 0) |> String.length()

      only_lowest = Enum.filter(sorted_by_len, fn x -> String.length(x) == lowest_len end)
      |> IO.inspect(label: "only_lowest")

    end)
    |> IO.inspect(label: "between 1 and 2")
    |> Enum.map(fn arrangements ->
      IO.inspect(arrangements)
      Enum.map(arrangements, fn arrangement ->
        split = String.split(arrangement, "", trim: true)
        |> IO.inspect(label: "split")
        bot3_bot2_encoded = Enum.reduce(split, {"A", [""]}, fn desired, {state, move_arrangements} ->
          valid_moves = get_bot_action(state, desired, :arrowpad)

          new_move_arrangements = Enum.map(move_arrangements, fn move ->
            Enum.map(valid_moves, fn valid_move -> move <> valid_move <> "A" end)
          end)
          |> List.flatten()

          {desired, new_move_arrangements}
        end)
        |> elem(1)
        |> IO.inspect(label: "bot3_bot2_encoded")

        sorted_by_len = Enum.uniq(bot3_bot2_encoded)
        |> Enum.sort_by(&String.length/1)
        |> IO.inspect(label: "sorted_by_len")
        lowest_len = Enum.at(sorted_by_len, 0) |> String.length()

        only_lowest = Enum.filter(sorted_by_len, fn x -> String.length(x) == lowest_len end)
        |> IO.inspect(label: "only_lowest")
      end)
      |> List.flatten()
      |> Enum.uniq()
    end)
    |> IO.inspect(label: "between 2 and 3")
    |> Enum.map(fn arrangements ->
      IO.inspect(arrangements, label: "arrangements3")
      IO.inspect(Enum.count(arrangements), label: "arrangements3_count")
      Enum.map(Enum.take(arrangements, 10), fn arrangement ->
        split = String.split(arrangement, "", trim: true)
        me_bot3_encoded = Enum.reduce(split, {"A", [""]}, fn desired, {state, move_arrangements} ->
          valid_moves = get_bot_action(state, desired, :arrowpad)

          new_move_arrangements = Enum.map(move_arrangements, fn move ->
            Enum.map(valid_moves, fn valid_move -> move <> valid_move <> "A" end)
          end)
          |> List.flatten()
          |> Enum.uniq()

          {desired, new_move_arrangements}
        end)
        |> elem(1)
        # |> IO.inspect(label: "me_bot3_encoded")

        sorted_by_len = Enum.sort_by(me_bot3_encoded, &String.length/1)
        lowest_len = Enum.at(sorted_by_len, 0) |> String.length()

        only_lowest = Enum.filter(sorted_by_len, fn x -> String.length(x) == lowest_len end)
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.at(0)
    end)


    Enum.with_index(to_enter)
    |> Enum.map(fn {to_enter_line, index} ->
      original = Enum.at(parsed, index)
      |> Enum.join()
      IO.inspect(to_enter_line)

      orig_numerical = String.replace(original, ~r/\D/, "")
      |> String.to_integer()

      IO.inspect({String.length(to_enter_line), orig_numerical})
      String.length(to_enter_line) * orig_numerical
    end)
    |> Enum.sum()

  end

  # bug here... for some reason with 379A input, we aren't finding the shorest route, even when we kill the dot avoid code.
  # shortest we find is
  # <<vA>>^AvA^A<<vA>>^AA<<vA>A>^AA<A>vAA^A<vA>^AA<A>A<<vA>A>^AAA<A>vA^A
  # where a shortest provided is
  # <v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A

  # I'm had made the assumption that we would always want to go all
  # in one direction before the other, but I'm beginning to wonder if that was
  # wrong. I might need to try all arrangements of x and y changes
  # so all possible paths between the two points.
  # I worry that will be super slow though.

  # 181666 too high
  # got that by finagling until I fit the test but no luck
  # even with memoization I can't really test all possible paths
  # it gets big fast.
  # unsure how to proceed at this point so heading to bed.

  def part2(input) do
  end
end
