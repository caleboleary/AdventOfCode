defmodule AdventOfCode.Day08 do

  defp three_d_dist({x1, y1, z1}, {x2, y2, z2}) do
    :math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2)
  end

  def part1(input, test \\ false) do
    coords = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, z] = String.split(line, ",", trim: true)
      {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
    end)

    dist_between_all_pairs = coords
    |> Enum.map(fn coord1 ->
      Enum.map(coords, fn coord2 ->
        {{coord1, coord2}, three_d_dist(coord1, coord2)}
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {{c1, c2}, _dist} -> c1 != c2 end)

    deduped_dist_between_all_pairs = dist_between_all_pairs
    |> Enum.reduce(%{}, fn {{c1, c2}, dist}, acc ->
      key = if c1 < c2, do: {c1, c2}, else: {c2, c1}
      Map.put(acc, key, dist)
    end)
    |> Enum.map(fn {key, dist} -> {key, dist} end)
    |> IO.inspect(label: "Deduped Distances")


    smallest_distances = Enum.sort_by(deduped_dist_between_all_pairs, fn {{_c1, _c2}, dist} -> dist end)
    |> IO.inspect(label: "Sorted Distances")

    connections_to_make = if test do
      10
    else
      1000
    end

    circuits = Enum.reduce_while(smallest_distances, {[], 0}, fn {{c1, c2}, _dist}, {acc, connections_made} ->

      if connections_made >= connections_to_make do
        {:halt, acc}
      else
        # IO.inspect("----------------------")

        # IO.inspect({c1, c2}, label: "Considering connection")
        lengths = Enum.map(acc, fn circuit -> length(circuit) end)
        # |> IO.inspect(label: "Current circuit lengths")



        # if we can find either coord in an existing circuit, add the pair to that circuit
        # [ [ {1,1,1}, {2,2,2}, {3,3,3} ], [ {4,4,4}, {5,5,5} ] ]
        found = Enum.filter(acc, fn circuit ->
          Enum.any?(circuit, fn coord -> coord == c1 or coord == c2 end)
        end)
        # if we find 2, we need to merge the circuits
        # if we find 1, we add to that circuit
        # if we find 0, we create a new circuit
        case length(found) do
          0 ->
            newacc = acc ++ [ [c1, c2] ]
            # IO.inspect("new circuit created")
            {:cont, {newacc, connections_made + 1}}
            # |> IO.inspect(label: "New Acc")
          1 ->

            # do both halves already exist anywhere in the circuit?
            already_connected_left = Enum.member?(Enum.at(found, 0), c1)
            # |> IO.inspect(label: "Already connected left?")
            already_connected_right = Enum.member?(Enum.at(found, 0), c2)
            # |> IO.inspect(label: "Already connected right?")
            if already_connected_left and already_connected_right do
              # IO.inspect("both already connected, skipping")
              {:cont, {acc, connections_made + 1}}
              # |> IO.inspect(label: "New Acc")
            else

              circuit = Enum.at(found, 0)
              updated_circuit = (circuit ++ [c1, c2]) |> Enum.uniq()
              acc_without_circuit = acc |> Enum.filter(fn c -> c != circuit end)
              newacc = acc_without_circuit ++ [updated_circuit]
              # IO.inspect("added to existing circuit")
              {:cont, {newacc, connections_made + 1}}
              # |> IO.inspect(label: "New Acc")
            end
          2 ->
            circuit1 = Enum.at(found, 0)
            circuit2 = Enum.at(found, 1)
            merged_circuit = (circuit1 ++ circuit2 ++ [c1, c2]) |> Enum.uniq()
            acc_without_circuits = acc |> Enum.filter(fn c -> c != circuit1 and c != circuit2 end)
            newacc = acc_without_circuits ++ [merged_circuit]
            # IO.inspect("merged two circuits")
            {:cont, {newacc, connections_made + 1}}
            # |> IO.inspect(label: "New Acc")

          _ ->
            throw "AHHHHHHHHHHH"
        end

      end


    end)
    |> IO.inspect(label: "Circuits")
    |> Enum.map(fn circuit ->
      circuit
      |> length()
    end)
    |> IO.inspect(label: "Circuit Lengths")
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.reduce(1, fn len, acc -> len * acc end)




  end

  def part2(input) do

    coords = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, z] = String.split(line, ",", trim: true)
      {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
    end)

    dist_between_all_pairs = coords
    |> Enum.map(fn coord1 ->
      Enum.map(coords, fn coord2 ->
        {{coord1, coord2}, three_d_dist(coord1, coord2)}
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {{c1, c2}, _dist} -> c1 != c2 end)

    deduped_dist_between_all_pairs = dist_between_all_pairs
    |> Enum.reduce(%{}, fn {{c1, c2}, dist}, acc ->
      key = if c1 < c2, do: {c1, c2}, else: {c2, c1}
      Map.put(acc, key, dist)
    end)
    |> Enum.map(fn {key, dist} -> {key, dist} end)
    |> IO.inspect(label: "Deduped Distances")


    smallest_distances = Enum.sort_by(deduped_dist_between_all_pairs, fn {{_c1, _c2}, dist} -> dist end)
    |> IO.inspect(label: "Sorted Distances")



    circuits = Enum.reduce_while(smallest_distances, {[], nil}, fn {{c1, c2}, _dist}, {acc, last_connection} ->

      if acc |> length() == 1 && Enum.at(acc, 0) |> length() == length(coords) do
        IO.inspect("All connected!")
        IO.inspect(last_connection, label: "Last connection made")
        {:halt, last_connection}
      else
        # IO.inspect("----------------------")

        # IO.inspect({c1, c2}, label: "Considering connection")
        lengths = Enum.map(acc, fn circuit -> length(circuit) end)
        # |> IO.inspect(label: "Current circuit lengths")



        # if we can find either coord in an existing circuit, add the pair to that circuit
        # [ [ {1,1,1}, {2,2,2}, {3,3,3} ], [ {4,4,4}, {5,5,5} ] ]
        found = Enum.filter(acc, fn circuit ->
          Enum.any?(circuit, fn coord -> coord == c1 or coord == c2 end)
        end)
        # if we find 2, we need to merge the circuits
        # if we find 1, we add to that circuit
        # if we find 0, we create a new circuit
        case length(found) do
          0 ->
            newacc = acc ++ [ [c1, c2] ]
            # IO.inspect("new circuit created")
            {:cont, {newacc, {c1, c2}}}
            # |> IO.inspect(label: "New Acc")
          1 ->

            # do both halves already exist anywhere in the circuit?
            already_connected_left = Enum.member?(Enum.at(found, 0), c1)
            # |> IO.inspect(label: "Already connected left?")
            already_connected_right = Enum.member?(Enum.at(found, 0), c2)
            # |> IO.inspect(label: "Already connected right?")
            if already_connected_left and already_connected_right do
              # IO.inspect("both already connected, skipping")
              {:cont, {acc, {c1, c2}}}
              # |> IO.inspect(label: "New Acc")
            else

              circuit = Enum.at(found, 0)
              updated_circuit = (circuit ++ [c1, c2]) |> Enum.uniq()
              acc_without_circuit = acc |> Enum.filter(fn c -> c != circuit end)
              newacc = acc_without_circuit ++ [updated_circuit]
              # IO.inspect("added to existing circuit")
              {:cont, {newacc, {c1, c2}}}
              # |> IO.inspect(label: "New Acc")
            end
          2 ->
            circuit1 = Enum.at(found, 0)
            circuit2 = Enum.at(found, 1)
            merged_circuit = (circuit1 ++ circuit2 ++ [c1, c2]) |> Enum.uniq()
            acc_without_circuits = acc |> Enum.filter(fn c -> c != circuit1 and c != circuit2 end)
            newacc = acc_without_circuits ++ [merged_circuit]
            # IO.inspect("merged two circuits")
            {:cont, {newacc, {c1, c2}}}
            # |> IO.inspect(label: "New Acc")

          _ ->
            throw "AHHHHHHHHHHH"
        end

      end


    end)
    |> then(fn {l, r} ->
      elem(r, 0) * elem(l, 0)
    end)

  end
end
