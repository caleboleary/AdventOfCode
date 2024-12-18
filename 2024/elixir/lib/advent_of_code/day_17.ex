defmodule AdventOfCode.Day17 do

  defp get_parsed_input(input) do
    [reg, prog] = input
    |> String.split("\n\n", trim: true)

    program = prog
    |> String.replace("Program: ", "")
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)

    registers = reg
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, ": ", trim: true) end)
    |> Enum.map(fn [k, v] -> {String.replace(k, "Register ", "") |> String.downcase() |> String.to_atom(), String.to_integer(v)} end)
    |> Enum.into(%{})

    {registers, program}
  end

  defp process_iteration(registers, program, pointer, out) do
    instr = Enum.at(program, pointer)
    operand = Enum.at(program, pointer + 1)

    # IO.inspect(instr, label: "instr")
    # IO.inspect(operand, label: "operand")
    # IO.inspect(registers, label: "registers")

    combo_operand = case operand do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> registers.a
      5 -> registers.b
      6 -> registers.c
      7 -> nil
      _ -> throw "invalid operand"
    end

    case instr do
      0 -> new_a = trunc(registers.a / Integer.pow(2, combo_operand))
        new_registers = Map.put(registers, :a, new_a)
        {:cont, %{registers: new_registers, pointer: pointer + 2, out: out}}
      1 -> new_b = Bitwise.bxor(registers.b, operand)
        new_registers = Map.put(registers, :b, new_b)
        {:cont, %{registers: new_registers, pointer: pointer + 2, out: out}}
      2 -> new_b = rem(combo_operand, 8)
        new_registers = Map.put(registers, :b, new_b)
        {:cont, %{registers: new_registers, pointer: pointer + 2, out: out}}
      3 -> cond do
        registers.a == 0 -> {:cont, %{registers: registers, pointer: pointer + 2, out: out}}
        true -> {:cont, %{registers: registers, pointer: operand, out: out}}
      end
      4 -> new_b = Bitwise.bxor(registers.b, registers.c)
        new_registers = Map.put(registers, :b, new_b)
        {:cont, %{registers: new_registers, pointer: pointer + 2, out: out}}
      5 -> new_out_entry = rem(combo_operand, 8)
        IO.inspect(registers, label: "registers")
        {:cont, %{registers: registers, pointer: pointer + 2, out: [new_out_entry | out]}}
      6 -> new_b = trunc(registers.a / Integer.pow(2, combo_operand))
        new_registers = Map.put(registers, :b, new_b)
        {:cont, %{registers: new_registers, pointer: pointer + 2, out: out}}
      7 -> new_c = trunc(registers.a / Integer.pow(2, combo_operand))
        new_registers = Map.put(registers, :c, new_c)
        {:cont, %{registers: new_registers, pointer: pointer + 2, out: out}}
      _ -> throw "invalid instruction"
    end
  end

  def part1(input) do

    {registers, program} = get_parsed_input(input)

    limit = 1000

    Enum.reduce_while(0..limit, %{registers: registers, pointer: 0, out: []}, fn i, acc ->

      if acc.pointer >= length(program) do
        {:halt, acc}
      else
        process_iteration(acc.registers, program, acc.pointer, acc.out)
        # |> IO.inspect(label: "processed")
      end

    end)
    |> Map.get(:out)
    |> Enum.reverse()
    |> Enum.join(",")

  end

  def part2(input) do
    # both the sample and the real input last 2 instructions are "out", "jump"
    # so my theory here is that we just need to figure out what we should set up so that
    # when we reach these last two, we just output first the first of self,
    # then jump back and output the second of self
    # etc
    # it feels like we need to work backwards

    # so looking at the sample
    # Program: 0,3,5,4,3,0
    # we first perform division (areg / 2^3) (areg / 8) and store it back in areg
    # then we walk into the output instruction ready to output areg mod 8

    # so knowing that we want the first output to be 0
    # we need to set areg to some number that, when divided by 8, is still divisible by 8 (64 for example)

    # if we run the program with 64 we get out
    # 0,1,0
    # so we've solved the first output (num divisble by 64)

    # moving to second output 3
    # we need the registers to be some numbner that, when divided by 8, has a remainder of 3
    # areg will still be our original value divided by 8
    # so to generate 0,3, we need some number that is divisible by 64 and then after it
    # has been divided by 64, has remainder of 3 when divided by 8
    # x % 64 == 0, x/64 % 8 == 3
    # 192 satisfies these, though I'm not sure how we get the algebra to find this.

    # if we run the program with 192 we get out
    # 0,3,0
    # so we've solved the second output (num divisble by 64, then remainder 3)

    # moving to third output 5
    # we need the registers to be some numbner that, when divided by 8, has a remainder of 5
    # areg will still be our original value divided by 64
    # so to generate 0,3,5, we need some number that is divisible by 64 and then after it
    # has been divided by 512 (8 cubed), has remainder of 5 when divided by 8
    # 2752 satisfies these, though I'm not sure how we get the algebra to find this.

    # if we run the program with 2752 we get out
    # 0,3,5,0

    # so I won't continue but what I'd like to do is write code which
    # takes in our program and can output the constraints on the value we want
    # then we can maybe brute force it to find the value that satisfies all constraints
    # thinking about what that entails, it sounds easier to do by hand
    # but I'd prefer to do it programatically for any input

    # maybe let's start out brute forcing what produces just the first instruction.

    # 23798685 gets the first 9(/16) correct
    # pattern of 2, 296, 923, 34715, 730011, 730013, 17507227, 23798683, 23798685
    # checked up to 1000000000

    # a thought. looking at the sample pattern, each time we circle back to the front of the program
    # the next logged output is based entirely on the state of the registers
    # so perhaps we can segment the program into chunks and brute force the register state?
    # though I think b and c registers might make that not doable...


    {registers, program} = get_parsed_input(input)

    rstart = 100000000
    rend = 1000000000

    Enum.reduce_while(rstart..rend, 1, fn i, acc ->

      # IO.inspect(i, label: "i")
      out = part1(input |> String.replace("Register A: 2024", "Register A: #{i}"))
      # out = part1(input |> String.replace("Register A: 64012472", "Register A: #{i}"))
      # |> IO.inspect(label: "out")

      split = String.split(out, ",")
      |> Enum.map(&String.to_integer/1)

      if Enum.slice(split, 0, acc) == Enum.slice(program, 0, acc) do
        IO.inspect("a new higher match found")
        IO.inspect(i, label: "i")
        IO.inspect(Enum.slice(split, 0, acc), label: "split")
        {:cont, acc + 1}
      else
        {:cont, acc}
      end

      # if split |> Enum.at(0) == program |> Enum.at(0) && split |> Enum.at(1) == program |> Enum.at(1) do
      #   {:halt, i}
      # else
      #   {:cont, nil}
      # end

    end)



  end
end
