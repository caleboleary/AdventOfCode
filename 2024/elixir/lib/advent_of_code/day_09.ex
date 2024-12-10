defmodule AdventOfCode.Day09 do
  @moduledoc """
  This one was not so fun for me, I wasted a lot of time essentially doing exactly how the
  samples are shown, in string format

  This is both slow and also impossible thanks to index growing larger than 9
  so I scrapped all of it and ended up with the map approach

  I feel a little bit like the samples lead the wrong direction but I got there eventually
  """

  defp parse_input(input) do
    input
    |> String.trim()

  end

  defp uncompress(disk_map) do
    Enum.with_index(disk_map)
    |> Enum.reduce({[], 0, 0}, fn ({char, index}, {old_list, old_empty, old_filled}) ->
      if rem(index, 2) == 0 do
        id = floor(index / 2)
        new_list = List.duplicate(%{id: id}, char)

        {old_list ++ new_list, old_empty, old_filled + char}
      else
        new_list = List.duplicate(%{id: :empty}, char)

        {old_list ++ new_list, old_empty + char, old_filled}
      end
    end)
  end

  defp migrate_leftward(uncompressed_disk_map, filled_count) do
    back_portion = Enum.take(uncompressed_disk_map, filled_count * -1)
    |> Enum.reverse()
    |> Enum.filter(fn x -> x.id != :empty end)

    Enum.reduce_while(back_portion, %{
      solidified: [],
      in_flux: uncompressed_disk_map
    }, fn current_mem_block, acc ->

      solidified = acc.solidified
      in_flux = acc.in_flux

      if length(solidified) >= filled_count do
        {:halt, Enum.take(solidified, filled_count)}
      else
        # here I'm responsible for simply moving this current_mem_block to the leftmost dot's position
        # and then heading to next iter with updated solidified, and in_flux
        # where solidified is the portion of the entire uncompressed disk map with no empties
        # and in_flux is the rest.

        # so.

        # find leftmost empty index in in_flux
        leftmost_empty_index = Enum.find_index(in_flux, fn x -> x.id == :empty end)

        # create new solidifed and in_flux
        new_solidified = solidified ++ Enum.slice(in_flux, 0, leftmost_empty_index) ++ [current_mem_block]
        new_in_flux = Enum.drop(in_flux, leftmost_empty_index + 1)

        {:cont, %{solidified: new_solidified, in_flux: new_in_flux}}
      end

    end)
  end

  defp calc_checksum(migrated_disk_map) do
    Enum.with_index(migrated_disk_map)
    |> Enum.reduce(0, fn ({mem_block, index}, acc) ->
      if mem_block.id == :empty do
        acc
      else
        acc + (mem_block.id * index)
      end
    end)
  end

  def part1(input) do
    parsed = parse_input(input)

    {uncompressed, _empty_count, filled_count} = String.split(parsed, "", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> uncompress()

    migrated = migrate_leftward(uncompressed, filled_count)

    calc_checksum(migrated)
  end

  defp uncompress_whole_files(disk_map) do
    Enum.with_index(disk_map)
    |> Enum.reduce([], fn ({char, index}, acc) ->
      if rem(index, 2) == 0 do
        id = floor(index / 2)
        new_list = [%{id: id, size: char}]

        acc ++ new_list
      else
        new_list = [%{id: :empty, size: char}]

        acc ++ new_list
      end
    end)
  end

  # defp text_vizualize_disk_map(uncompressed_disk_map) do
  #   Enum.map(uncompressed_disk_map, fn x ->
  #     if x.id == :empty do
  #       List.duplicate(".", x.size) |> Enum.join()
  #     else
  #       List.duplicate("#{x.id}", x.size) |> Enum.join()
  #     end
  #   end)
  #   |> Enum.join()
  #   |> IO.inspect(label: "disk_map")
  # end

  defp migrate_whole_files_leftward(uncompressed_disk_map) do
    Enum.with_index(uncompressed_disk_map)
    |> Enum.filter(fn {x, _} -> x.id != :empty end)
    |> Enum.reverse()
    |> Enum.reduce(uncompressed_disk_map, fn {current_mem_block, _current_index}, acc ->
      candidate_location = Enum.find_index(acc, fn x -> x.id == :empty && x.size >= current_mem_block.size end)

      updated_current_index = Enum.find_index(acc, fn x -> x.id == current_mem_block.id end)

      new_acc = cond do
        candidate_location == nil ->
          acc
        candidate_location > updated_current_index ->
          acc
        Enum.at(acc, candidate_location).size == current_mem_block.size ->

          Enum.slice(acc, 0, candidate_location)
          ++ [current_mem_block]
          ++ Enum.slice(acc, candidate_location + 1, updated_current_index - candidate_location - 1)
          ++ [Enum.at(acc, candidate_location)]
          ++ Enum.slice(acc, updated_current_index + 1, length(acc))
        Enum.at(acc, candidate_location).size > current_mem_block.size ->
          Enum.slice(acc, 0, candidate_location)
          ++ [current_mem_block]
          ++ [%{
            id: :empty,
            size: Enum.at(acc, candidate_location).size - current_mem_block.size
          }]
          ++ Enum.slice(acc, candidate_location + 1, updated_current_index - candidate_location - 1)
          ++ [%{
            id: :empty,
            size: current_mem_block.size
          }]
          ++ Enum.slice(acc, updated_current_index + 1, length(acc))
      end

      new_acc
    end)
  end

  defp calc_checksum_p2(migrated_disk_map) do
    Enum.reduce(migrated_disk_map, %{block_index: 0, total: 0}, fn x, acc ->
      block_index = acc.block_index
      total = acc.total

      if x.id == :empty do
        %{
          block_index: block_index + x.size,
          total: total
        }
      else
        file_total = Enum.map(block_index..(block_index + x.size - 1), fn y -> y * x.id end)
        |> Enum.sum()
        %{
          block_index: block_index + x.size,
          total: total + file_total
        }
      end
    end)
    |> Map.get(:total)
  end

  def part2(input) do
    parsed = parse_input(input)

    uncompressed = String.split(parsed, "", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> uncompress_whole_files()

    migrated = migrate_whole_files_leftward(uncompressed)

    Enum.map(migrated, fn x ->
     if x.id == :empty do
       "."
     else
      x.id
     end
    end)
    |> Enum.join()

    calc_checksum_p2(migrated)
  end
end
