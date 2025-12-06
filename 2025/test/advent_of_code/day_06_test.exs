defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  @tag :skip
  test "part1" do
    input = "123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +  "
    result = part1(input)

    assert result == 4277556
  end

  # @tag :skip
  test "part2" do
    input = "123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +  "

#     input = "4673 961 82 8   26 12
# 4869 357 97 13  27 898
# 283  259 58 69  39 592
# 441   47 94 596 35 288
# +    +   *  *   *  *  "
    result = part2(input)

    assert result == 3263827
  end
end
