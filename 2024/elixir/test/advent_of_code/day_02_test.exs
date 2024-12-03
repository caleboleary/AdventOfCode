defmodule AdventOfCode.Day02Test do
  use ExUnit.Case

  import AdventOfCode.Day02

  @sample "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

  @tag :skip
  test "part1" do
    input = @sample
    result = part1(input)

    assert result == 2
  end

  @tag :skip
  test "part2" do
    input = @sample
    result = part2(input)

    assert result == 4
  end
end
