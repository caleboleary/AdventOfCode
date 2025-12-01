defmodule AdventOfCode.Day22Test do
  use ExUnit.Case

  import AdventOfCode.Day22

  @tag :skip
  test "part1" do
    input = "1
10
100
2024"
    result = part1(input)

    assert result == 37327623
  end

  # @tag :skip
  test "part2" do
    input = "1
2
3
2024"
    result = part2(input)

    assert result == "-2,1,-1,3"
  end
end
