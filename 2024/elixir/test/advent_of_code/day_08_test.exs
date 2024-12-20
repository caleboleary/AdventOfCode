defmodule AdventOfCode.Day08Test do
  use ExUnit.Case

  import AdventOfCode.Day08

  @tag :skip
  test "part1" do
    input = "............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"

# input = "..........
# ..........
# ..........
# ....a.....
# ........a.
# .....a....
# ..........
# ..........
# ..........
# .........."
    result = part1(input)

    assert result == 14
  end

  @tag :skip
  test "part2" do

    input = "............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"

#     input = "T.........
# ...T......
# .T........
# ..........
# ..........
# ..........
# ..........
# ..........
# ..........
# .........."
    result = part2(input)

    assert result == 34
  end
end
