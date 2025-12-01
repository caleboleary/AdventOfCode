defmodule AdventOfCode.Day01 do
  def part1(input) do
    instructions = input
    |> String.split("\n", trim: true)

    dial_state = 50

    states = Enum.reduce(instructions, [dial_state], fn instruction, acc ->

      last_state = List.last(acc)
      direction = String.slice(instruction, 0, 1)
      distance = String.slice(instruction, 1..-1//1) |> String.to_integer() |> rem(100)

      new_state = case direction do
        "L" -> last_state - distance
        "R" -> last_state + distance
      end

      new_state = case new_state do
        n when n < 0 -> 100 + n
        n when n >= 100 -> n - 100
        n -> n
      end

      IO.inspect(new_state, label: "New State")
      acc ++ [new_state]
    end)

    states
    |> Enum.filter(fn x -> x == 0 end)
    |> length()
  end

  def part2(input) do
    instructions = input
    |> String.split("\n", trim: true)

    dial_state = 50
    rotations = 0

    states = Enum.reduce(instructions, [{dial_state, rotations}], fn instruction, acc ->

      {last_state, _last_rotations} = List.last(acc)
      direction = String.slice(instruction, 0, 1)
      distance = String.slice(instruction, 1..-1//1) |> String.to_integer()

      interim_state = case direction do
        "L" -> last_state - distance
        "R" -> last_state + distance
      end

      IO.inspect("----------------------------------")
      IO.inspect(direction, label: "Direction")
      IO.inspect(distance, label: "Distance")
      IO.inspect(interim_state, label: "Interim State")

      new_state = rem(rem(interim_state, 100) + 100, 100)

      IO.inspect(last_state, label: "Last State")
      IO.inspect(new_state, label: "New State After Modulo")

      full_rotations = floor(div(abs(interim_state - last_state), 100))
      IO.inspect(full_rotations, label: "Full Rotations")
      remaining = rem(distance, 100)

      steps_to_first_zero = case direction do
        "L" -> if last_state == 0, do: 100, else: last_state
        "R" -> if last_state == 0, do: 100, else: 100 - last_state
      end

      sub_100_rots = if remaining >= steps_to_first_zero, do: 1, else: 0
      IO.inspect(sub_100_rots, label: "Sub 100 Rotations")
      rotations = full_rotations + sub_100_rots
      IO.inspect({new_state, rotations}, label: "New State")



      IO.inspect("----------------------------------")

      acc ++ [{new_state, rotations}]
    end)

    states
    |> Enum.reduce(0, fn {_state, rotations}, acc -> acc + rotations end)
  end
end
