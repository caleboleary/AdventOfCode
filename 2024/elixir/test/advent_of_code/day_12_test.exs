defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  @tag :skip
  test "part1" do
    input = "AAAA
BBCD
BBCC
EEEC"
    result = part1(input)

    assert result == 140
  end

  @tag :skip
  test "part2" do
    input = "AAAA
BBCD
BBCC
EEEC"
    result = part2(input)

    assert result == 80
  end
end
