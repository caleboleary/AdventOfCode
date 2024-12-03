defmodule AdventOfCode.Day01 do
  def part1(input) do
    IO.inspect(input)

    lines = String.split(input, "\n", trim: true)
    leftList = Enum.map(lines, fn line -> String.split(line, " ", trim: true) |> List.first() |> String.to_integer() end)
    rightList = Enum.map(lines, fn line -> String.split(line, " ", trim: true) |> List.last() |> String.to_integer() end)

    leftSorted = Enum.sort(leftList)
    rightSorted = Enum.sort(rightList)

    IO.inspect(leftSorted)
    IO.inspect(rightSorted)

    length = Enum.count(leftSorted)

    distances = Enum.map(0..length - 1, fn i ->
      l = Enum.at(leftSorted, i)
      r = Enum.at(rightSorted, i)

      abs(l - r)
    end)

    IO.inspect(distances)

    Enum.reduce(distances, 0, fn x, acc -> x + acc end)
  end

  def part2(input) do

    lines = String.split(input, "\n", trim: true)
    leftList = Enum.map(lines, fn line -> String.split(line, " ", trim: true) |> List.first() |> String.to_integer() end)
    rightList = Enum.map(lines, fn line -> String.split(line, " ", trim: true) |> List.last() |> String.to_integer() end)

    Enum.map(leftList, fn lNum ->

      countInRight = Enum.count(rightList, fn rNum -> rNum == lNum end)

      lNum * countInRight

    end)
    |> Enum.reduce(0, fn x, acc -> x + acc end)
  end
end
