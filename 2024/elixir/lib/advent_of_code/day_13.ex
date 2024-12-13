defmodule AdventOfCode.Day13 do

  defp get_parsed_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn machine ->
      lines = machine
      |> String.split("\n", trim: true)
      |> IO.inspect(label: "lines")

      a = Enum.at(lines, 0)
      |> String.split("Button A: ")
      |> List.last()
      |> String.split(", ")
      |> Enum.map(&String.split(&1, "+"))
      |> Enum.map(&List.last/1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

      b = Enum.at(lines, 1)
      |> String.split("Button B: ")
      |> List.last()
      |> String.split(", ")
      |> Enum.map(&String.split(&1, "+"))
      |> Enum.map(&List.last/1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

      prize = Enum.at(lines, 2)
      |> String.split("Prize: ")
      |> List.last()
      |> String.split(", ")
      |> Enum.map(&String.split(&1, "="))
      |> Enum.map(&List.last/1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

      %{
        a: a,
        b: b,
        prize: prize
      }

    end)

  end

  defp get_cheapest_prize(machine) do
    max_presses = 100
    possible_positions_a = Enum.reduce(0..max_presses, [], fn press, acc ->
      x = elem(machine.a, 0) * press
      y = elem(machine.a, 1) * press
      acc ++ [%{move: {x, y}, presses: press}]
    end)

    possible_positions_b = Enum.reduce(0..max_presses, [], fn press, acc ->
      x = elem(machine.b, 0) * press
      y = elem(machine.b, 1) * press
      acc ++ [%{move: {x, y}, presses: press}]
    end)

    combinations_hitting_prize = Enum.reduce(possible_positions_a, [], fn a, acc ->
      Enum.reduce(possible_positions_b, acc, fn b, acc ->
        a_presses = a.presses
        a_x = a.move |> elem(0)
        a_y = a.move |> elem(1)

        b_presses = b.presses
        b_x = b.move |> elem(0)
        b_y = b.move |> elem(1)

        if (a_x + b_x) == elem(machine.prize, 0) and (a_y + b_y) == elem(machine.prize, 1) do
          acc ++ [%{a: a_presses, b: b_presses}]
        else
          acc
        end

      end)
    end)|> IO.inspect(label: "combinations_hitting_prize")

    if Enum.empty?(combinations_hitting_prize) do
      0
    else
      Enum.map(combinations_hitting_prize, fn combo ->
        (combo.a * 3) + combo.b
      end)
      |> IO.inspect(label: "presses")
      |> Enum.sort()
      |> List.first()
    end
  end

  def part1(input) do
    parsed = get_parsed_input(input)
    |> IO.inspect()

    Enum.map(parsed, fn machine ->
      get_cheapest_prize(machine)
    end)
    |> Enum.sum()

  end


  # 94a + 22b = 8400
  # 34a + 67b = 5400

  # 34a + 67b = 5400
  # * (94/34)
  # 94a + 185.23529411764704b = 14929.411764705883

  # (94a + 185.23529411764704b) - (94a + 22b) = 14929.411764705883 - 8400
  # 163.23529411764704b = 6529.411764705883

  # 6529.411764705883 / 163.23529411764704 = 40.00000000000001

  # 94a + 22(40) = 8400
  # 94a + 880 = 8400
  # 94a = 7520
  # a = 80

  defp get_cheapest_prize_p2(machine) do
    # solving for b like above
    diff = (machine.a |> elem(0)) / (machine.a |> elem(1))
    |> IO.inspect(label: "diff")
    equivalent_second_equation_left = ((machine.b |> elem(1)) * diff) - (machine.b |> elem(0))
    |> IO.inspect(label: "equivalent_second_equation_left")
    equivalent_second_equation_right = ((machine.prize |> elem(1)) * diff) - (machine.prize |> elem(0))
    |> IO.inspect(label: "equivalent_second_equation_right")

    b = equivalent_second_equation_right / equivalent_second_equation_left
    |> IO.inspect(label: "b-preround")
    |> round()
    |> IO.inspect(label: "b")

    equivalent_first_equation_left = machine.a |> elem(0)
    |> IO.inspect(label: "equivalent_first_equation_left")
    equivalent_first_equation_right = (machine.prize |> elem(0)) - ((machine.b |> elem(0)) * b)
    |> IO.inspect(label: "equivalent_first_equation_right")

    a = equivalent_first_equation_right / equivalent_first_equation_left
    |> IO.inspect(label: "a")

    a_base = trunc(a)
    b_base = trunc(b)

    -2..2
    |> Enum.flat_map(fn da ->
      -2..2
      |> Enum.map(fn db ->
        {a_base + da, b_base + db}
      end)
    end)
    |> Enum.filter(fn {a_try, b_try} ->
      a_try > 0 && b_try > 0 &&
      abs((machine.a |> elem(0)) * a_try + (machine.b |> elem(0)) * b_try - (machine.prize |> elem(0))) < 0.0001 &&
      abs((machine.a |> elem(1)) * a_try + (machine.b |> elem(1)) * b_try - (machine.prize |> elem(1))) < 0.0001
    end)
    |> Enum.map(fn {a_try, b_try} -> (a_try * 3) + b_try end)
    |> Enum.min(fn -> 0 end)

  end

  # 66879125870448 too low
  # 77935303482426 too high crap

  # 75596115797987 wrong - no high or low, so maybe close or too many wrong?
  def part2(input) do
    parsed = get_parsed_input(input)
    |> IO.inspect()
    |> Enum.map(fn machine ->
      %{
        a: machine.a,
        b: machine.b,
        prize: {elem(machine.prize, 0) + 10000000000000, elem(machine.prize, 1) + 10000000000000}
      }
    end)

    Enum.map(parsed, fn machine ->
      get_cheapest_prize_p2(machine)
    end)
    |> Enum.filter(fn n ->
      n == n |> trunc() && n > 0
    end)
    |> IO.inspect(label: "presses")
    |> Enum.sum()

  end
end
