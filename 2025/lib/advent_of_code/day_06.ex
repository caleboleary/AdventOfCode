defmodule AdventOfCode.Day06 do
  def part1(input) do
    rows = input
    |> String.split("\n", trim: true)
    # |> IO.inspect(label: "rows")

    rows_and_cols = rows
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
    end)
    # |> IO.inspect(label: "rows_and_cols")

    operations = List.last(rows_and_cols)
    data_rows = Enum.slice(rows_and_cols, 0..-2)
    |> Enum.map(fn row ->
      Enum.map(row, fn val ->
        String.to_integer(val)
      end)
    end)
    # |> IO.inspect(label: "data_rows")

    Enum.with_index(operations)
    |> Enum.map(fn {op, i} ->
      col_values = Enum.map(data_rows, fn row ->
        Enum.at(row, i)
      end)
      # |> IO.inspect(label: "col_values #{i}")

      cond do
        op == "*" ->
          Enum.reduce(col_values, 1, fn x, acc -> x * acc end)
        op == "+" ->
          Enum.reduce(col_values, 0, fn x, acc -> x + acc end)
      end
    end)
    # |> IO.inspect(label: "results")
    |> Enum.reduce(0, fn x, acc -> x + acc end)

  end

  def part2(input) do
    split = input
    |> String.split("\n", trim: true)

    operations = List.last(split)
    |> String.split(" ", trim: true)
    |> Enum.reverse()

    rest = Enum.slice(split, 0..-2)

    width = rest |> Enum.at(0) |> String.split("") |> length()
    # |> IO.inspect(label: "width")
    height = rest |> length()
    # |> IO.inspect(label: "height")

    rotated = Enum.map(0..(width - 1), fn col_idx ->
      Enum.map(0..(height - 1), fn row_idx ->
        row = Enum.at(rest, row_idx)
        String.at(row, col_idx)
      end)
      |> Enum.join("")
    end)
    # |> IO.inspect(label: "joined")
    |> Enum.map(fn item ->
      if (String.trim(item) == "") do
        "BREAK"
      else
        item
      end
    end)
    # |> IO.inspect(label: "with breaks")
    |> Enum.chunk_by(fn x -> x == "BREAK" end)
    |> Enum.filter(fn x -> hd(x) != "BREAK" end)
    |> Enum.reverse()
    # |> IO.inspect(label: "rotated", limit: :infinity)

    Enum.with_index(operations)
    |> Enum.map(fn {op, i} ->
      col_values = Enum.at(rotated, i)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

      cond do
        op == "*" ->
          Enum.reduce(col_values, 1, fn x, acc -> x * acc end)
        op == "+" ->
          Enum.reduce(col_values, 0, fn x, acc -> x + acc end)
      end
    end)
    # |> IO.inspect(label: "results")
    |> Enum.reduce(0, fn x, acc -> x + acc end)

  end
end
