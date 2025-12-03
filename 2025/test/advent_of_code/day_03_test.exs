defmodule AdventOfCode.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Day03

  @tag :skip
  test "part1" do
    input = "987654321111111
811111111111119
234234234234278
818181911112111"
    result = part1(input)

    assert result == 357
  end

  @tag :skip
  test "part2" do
    input = "987654321111111
811111111111119
234234234234278
818181911112111"
    result = part2(input)

    assert result == 3121910778619
  end
end
