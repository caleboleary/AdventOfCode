defmodule Day21 do
  def get_input do
    # File.read!("./day21/day21testinput.txt")
    File.read!("./day21/day21input.txt")
        |> String.split("\n", trim: true)
  end

  def parse_input(input) do


    Enum.reduce(input, %{}, fn x, acc ->
      split = String.split(x, ":", trim: true)
      math = Enum.at(split, 1)
      |> String.split(" ", trim: true)

      Map.put(acc, Enum.at(split, 0),
        if Enum.at(math, 2) == nil do
          %{
            component1: nil,
            component2: nil,
            operation: nil,
            result: String.to_integer(Enum.at(math, 0))
          }
        else
          %{
            component1: Enum.at(math, 0),
            component2: Enum.at(math, 2),
            operation: Enum.at(math, 1),
            result: nil
          }
        end
      )
    end)
  end

  def perform_operation(one, two, op) do
    case op do
      "+" -> one + two
      "-" -> one - two
      "*" -> one * two
      "/" -> one / two
    end
  end

  def list_to_map(list) do
    Enum.reduce(list, %{}, fn {x, v}, acc ->
      Map.put(acc, x, v)
    end)
  end

  def get_sim_result(input) do
    Enum.reduce_while(0..100, input, fn x, acc ->
      #sim round
      updatedState = Enum.map(acc, fn {key, value} ->
      
        if value.result != nil do
          {key, value}
        else
          predecessor1 = Map.get(acc, value.component1).result
          predecessor2 = Map.get(acc, value.component2).result

          if predecessor1 != nil and predecessor2 != nil do
            if key == "root" do
              {key, %{value | result: {predecessor1, predecessor2}}}
            else
              {key, %{value | result: perform_operation(predecessor1, predecessor2, value.operation)}}
            end
          else
            {key, value}
          end
        end

      end) |> list_to_map()

      # IO.inspect("updatedState")
      # IO.inspect(updatedState)

      #is root value not nil?
      if Map.get(updatedState, "root").result != nil do
        {:halt, updatedState}
      else
        {:cont, updatedState}
      end
      
    end)
  end

  def recurse(input, key) do
    item = Map.get(input, key)

    if (item.component1 == nil) do
      if (key == "humn") do
        "(x)"
      else
        "#{item.result}"
      end
    else
      "(#{recurse(input, item.component1)} #{item.operation} #{recurse(input, item.component2)})"
    end
  end

  def extract_math_chain(simState) do
    #thinking as I write. looks like changing "humn" only changes one of the two parents of root
    #i'd like to extract the math that made that side of its tree
    #for test input I think it'd be something like 
    # rootLeft = pppw(cczh(sllz(4) + lgvd(ljgn(2) * ptdq(humn(x) - dvpt(3)))) / lfqf(4))
    # rootLeft = ((4) + ((2) * ((x) - (3)))) / (4)
    # ((4 + (2 * ((x) - 3))) / 4)

    {recurse(simState, Map.get(simState, "root").component1), recurse(simState, Map.get(simState, "root").component2)}


  end

  def main do
    input = get_input() |> parse_input()
    # IO.inspect(input)

    sim = get_sim_result(input)

    IO.inspect(sim)

    {chain1, chain2} = extract_math_chain(sim)

    variableChain = if (String.contains?(chain1, "x")) do
      chain1
    else
      chain2
    end

    # write variableChain to file
    # File.write!("./day21/day21variableChain.txt", variableChain)

    otherChain = if (String.contains?(chain1, "x")) do
      chain2
    else
      chain1
    end

    otherChainResult = Code.eval_string(otherChain)
    IO.inspect(otherChainResult)
    throw "a"

    Enum.reduce_while(0..1000000, 0, fn index, acc ->
      if (rem(index, 1000) == 0) do
        IO.inspect(index)
      end

      result = Code.eval_string(String.replace(variableChain, "x", to_string(index)))

      if (result == otherChainResult) do
        {:halt, index}
      else
        {:cont, acc}
      end


    end)


    

  end
end

IO.inspect(Day21.main())