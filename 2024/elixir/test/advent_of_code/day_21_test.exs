defmodule AdventOfCode.Day21Test do
  use ExUnit.Case

  import AdventOfCode.Day21

  @tag :skip
  test "part1" do
    input = "029A
980A
179A
456A
379A"
    result = part1(input)

    assert result == 126384
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
