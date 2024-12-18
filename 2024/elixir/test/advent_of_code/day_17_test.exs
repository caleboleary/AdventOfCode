defmodule AdventOfCode.Day17Test do
  use ExUnit.Case

  import AdventOfCode.Day17

  @tag :skip
  test "part1" do
    input = "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"
    result = part1(input)

    assert result == "4,6,3,5,6,3,5,2,1,0"
  end

  # @tag :skip
  test "part2" do
    input = "Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0"
    result = part2(input)

    assert result == 117440
  end
end
