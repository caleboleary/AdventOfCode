defmodule AdventOfCode.Day19Test do
  use ExUnit.Case

  import AdventOfCode.Day19

  @tag :skip
  test "part1" do
    input = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"
    result = part1(input)

    assert result == 6
  end

  @tag :skip
  test "part2" do
    input = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"
    result = part2(input)

    assert result == 16
  end
end
